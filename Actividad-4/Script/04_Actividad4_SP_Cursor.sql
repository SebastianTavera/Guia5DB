-- Actividad 4: SP con cursor que actualiza el estado de cada matricula de un curso

USE Guia_5;

-- 1. PREPARACION
-- agrega EstadoCurso solo si no existe
SET @existe = (SELECT COUNT(*) FROM information_schema.COLUMNS
               WHERE TABLE_SCHEMA = DATABASE()
                 AND TABLE_NAME   = 'Matricula'
                 AND COLUMN_NAME  = 'EstadoCurso');

SET @sql = IF(@existe = 0,
    'ALTER TABLE Matricula
         ADD COLUMN EstadoCurso VARCHAR(20) NOT NULL DEFAULT ''Sin evaluar''',
    'SELECT ''Columna EstadoCurso ya existe'' AS Aviso');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. CREACION DEL SP
DROP PROCEDURE IF EXISTS sp_actualizar_estado_curso;

DELIMITER //
CREATE PROCEDURE sp_actualizar_estado_curso(
    IN  p_IdGrupo  INT,
    OUT p_Mensaje  VARCHAR(200)
)
BEGIN
    DECLARE v_IdMatricula INT;
    DECLARE v_Nota        DECIMAL(3,2);
    DECLARE v_Estado      VARCHAR(20);
    DECLARE v_Fin         BOOLEAN DEFAULT FALSE;
    DECLARE v_Aprobados   INT DEFAULT 0;
    DECLARE v_Reprobados  INT DEFAULT 0;
    DECLARE v_Pendientes  INT DEFAULT 0;
    DECLARE v_ErrorSQL    VARCHAR(200);

    -- cursor: matriculas del curso
    DECLARE cur_matriculas CURSOR FOR
        SELECT IdMatricula, NotaFinal
        FROM Matricula
        WHERE IdGrupo = p_IdGrupo;

    -- marca el fin del recorrido
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Fin = TRUE;

    -- error SQL: deshace y lo devuelve
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_ErrorSQL = MESSAGE_TEXT;
        ROLLBACK;
        SET p_Mensaje = CONCAT('ERROR SQL: ', v_ErrorSQL);
    END;

    IF p_IdGrupo IS NULL THEN
        SET p_Mensaje = 'ERROR: el curso es obligatorio';

    ELSEIF NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = p_IdGrupo) THEN
        SET p_Mensaje = CONCAT('ERROR: el curso ', p_IdGrupo, ' no existe');

    ELSE
        START TRANSACTION;
        OPEN cur_matriculas;

        -- recorre fila por fila
        bucle: LOOP
            FETCH cur_matriculas INTO v_IdMatricula, v_Nota;
            IF v_Fin THEN
                LEAVE bucle;
            END IF;

            -- estado segun la nota final
            IF v_Nota IS NULL THEN
                SET v_Estado = 'Pendiente';
                SET v_Pendientes = v_Pendientes + 1;
            ELSEIF v_Nota >= 3.0 THEN
                SET v_Estado = 'Aprobado';
                SET v_Aprobados = v_Aprobados + 1;
            ELSE
                SET v_Estado = 'Reprobado';
                SET v_Reprobados = v_Reprobados + 1;
            END IF;

            -- actualiza solo la fila leida
            UPDATE Matricula
            SET EstadoCurso = v_Estado
            WHERE IdMatricula = v_IdMatricula;
        END LOOP bucle;

        CLOSE cur_matriculas;
        COMMIT;

        SET p_Mensaje = CONCAT('EXITO: curso ', p_IdGrupo, ' -> ',
                               v_Aprobados + v_Reprobados + v_Pendientes, ' matriculas (',
                               v_Aprobados, ' aprobadas, ', v_Reprobados, ' reprobadas, ',
                               v_Pendientes, ' pendientes)');
    END IF;
END //
DELIMITER ;

-- 3. ANTES (captura)
SELECT  m.IdMatricula,
        CONCAT(e.PrimerNombre, ' ', e.PrimerApellido) AS Estudiante,
        m.IdGrupo,
        m.NotaFinal,
        m.EstadoCurso
FROM Matricula m
JOIN Estudiante e ON e.IdEstudiante = m.IdEstudiante
WHERE m.IdGrupo = 1
ORDER BY m.IdMatricula;

-- 4. EJECUCION SOBRE EL CURSO 1
CALL sp_actualizar_estado_curso(1, @msg);
SELECT @msg AS Resultado;

-- 5. DESPUES (captura)
SELECT  m.IdMatricula,
        CONCAT(e.PrimerNombre, ' ', e.PrimerApellido) AS Estudiante,
        m.IdGrupo,
        m.NotaFinal,
        m.EstadoCurso
FROM Matricula m
JOIN Estudiante e ON e.IdEstudiante = m.IdEstudiante
WHERE m.IdGrupo = 1
ORDER BY m.IdMatricula;

-- resto de cursos
CALL sp_actualizar_estado_curso(2, @msg);
SELECT 2 AS Curso, @msg AS Resultado;
CALL sp_actualizar_estado_curso(3, @msg);
SELECT 3 AS Curso, @msg AS Resultado;
CALL sp_actualizar_estado_curso(4, @msg);
SELECT 4 AS Curso, @msg AS Resultado;
CALL sp_actualizar_estado_curso(5, @msg);
SELECT 5 AS Curso, @msg AS Resultado;

-- casos invalidos
CALL sp_actualizar_estado_curso(99, @msg);
SELECT 99 AS Curso, @msg AS Resultado;
CALL sp_actualizar_estado_curso(NULL, @msg);
SELECT NULL AS Curso, @msg AS Resultado;

-- 6. RESUMEN POR CURSO (captura)
SELECT  m.IdGrupo,
        ma.NombreMateria AS Curso,
        SUM(m.EstadoCurso = 'Aprobado')  AS Aprobados,
        SUM(m.EstadoCurso = 'Reprobado') AS Reprobados,
        SUM(m.EstadoCurso = 'Pendiente') AS Pendientes
FROM Matricula m
JOIN Grupo g    ON g.IdGrupo    = m.IdGrupo
JOIN Materia ma ON ma.IdMateria = g.IdMateria
GROUP BY m.IdGrupo, ma.NombreMateria
ORDER BY m.IdGrupo;
