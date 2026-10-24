-- Practica 5 - Actividad 1: Primer procedimiento almacenado
-- Sistema: Guia_5
-- SP que registra una matricula y devuelve exito/error por parametro OUT
-- Nota: en este esquema el "curso" es la tabla Grupo (IdGrupo)
-- Compatible: MySQL 8.x y MariaDB 10.5+

USE Guia_5;

-- 1. CREACION DEL SP
DROP PROCEDURE IF EXISTS sp_registrar_matricula;

DELIMITER //
CREATE PROCEDURE sp_registrar_matricula(
    IN  p_IdEstudiante INT,           -- estudiante a matricular
    IN  p_IdGrupo      INT,           -- curso (grupo) destino
    OUT p_Mensaje      VARCHAR(200)   -- resultado para quien llama
)
BEGIN
    DECLARE v_NuevoId   INT;
    DECLARE v_Cupo      INT;
    DECLARE v_Inscritos INT;
    DECLARE v_Creditos  INT;
    DECLARE v_ErrorSQL  VARCHAR(200);

    -- si falla cualquier sentencia SQL: deshace y devuelve el error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_ErrorSQL = MESSAGE_TEXT;
        ROLLBACK;
        SET p_Mensaje = CONCAT('ERROR SQL: ', v_ErrorSQL);
    END;

    -- valida que lleguen los dos parametros
    IF p_IdEstudiante IS NULL OR p_IdGrupo IS NULL THEN
        SET p_Mensaje = 'ERROR: estudiante y curso son obligatorios';

    -- valida que el estudiante exista
    ELSEIF NOT EXISTS (SELECT 1 FROM Estudiante WHERE IdEstudiante = p_IdEstudiante) THEN
        SET p_Mensaje = CONCAT('ERROR: el estudiante ', p_IdEstudiante, ' no existe');

    -- valida que el curso exista
    ELSEIF NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = p_IdGrupo) THEN
        SET p_Mensaje = CONCAT('ERROR: el curso ', p_IdGrupo, ' no existe');

    -- evita matricular dos veces al mismo estudiante en el mismo curso
    ELSEIF EXISTS (SELECT 1 FROM Matricula
                   WHERE IdEstudiante = p_IdEstudiante AND IdGrupo = p_IdGrupo) THEN
        SET p_Mensaje = 'ERROR: el estudiante ya esta matriculado en ese curso';

    ELSE
        START TRANSACTION;

        -- revisa el cupo (NULL = cupo ilimitado)
        SELECT Cupo INTO v_Cupo FROM Grupo WHERE IdGrupo = p_IdGrupo FOR UPDATE;
        SELECT COUNT(*) INTO v_Inscritos FROM Matricula WHERE IdGrupo = p_IdGrupo;

        IF v_Cupo IS NOT NULL AND v_Inscritos >= v_Cupo THEN
            ROLLBACK;
            SET p_Mensaje = CONCAT('ERROR: el curso ', p_IdGrupo, ' no tiene cupo (',
                                   v_Inscritos, '/', v_Cupo, ')');
        ELSE
            -- siguiente IdMatricula (la PK no es AUTO_INCREMENT)
            SELECT COALESCE(MAX(IdMatricula), 0) + 1 INTO v_NuevoId FROM Matricula;

            -- valor segun creditos: 200.000 + 250.000 por credito (mismo patron de los datos)
            SELECT m.CreditosMateria INTO v_Creditos
            FROM Grupo g JOIN Materia m ON m.IdMateria = g.IdMateria
            WHERE g.IdGrupo = p_IdGrupo;

            -- esta parte crea la matricula con la fecha actual y sin nota
            INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo,
                                   FechaMatricula, NotaFinal, ValorMatricula)
            VALUES (v_NuevoId, p_IdEstudiante, p_IdGrupo,
                    CURDATE(), NULL, 200000 + v_Creditos * 250000);

            COMMIT;
            SET p_Mensaje = CONCAT('EXITO: matricula ', v_NuevoId,
                                   ' registrada para el estudiante ', p_IdEstudiante,
                                   ' en el curso ', p_IdGrupo);
        END IF;
    END IF;
END //
DELIMITER ;

-- 2. ESTADO ANTES DE LAS PRUEBAS (captura)
SELECT * FROM Matricula ORDER BY IdMatricula;

-- 3. PRUEBA CON DATOS VALIDOS

-- matricula a Andres Duenas en Teoria de BD (grupo 1)
CALL sp_registrar_matricula(1030281186, 1, @msg);
SELECT @msg AS Resultado;

-- matricula a Joan Romagna en Probabilidad (grupo 3)
CALL sp_registrar_matricula(1028886975, 3, @msg);
SELECT @msg AS Resultado;

-- 4. PRUEBAS CON DATOS INVALIDOS

-- estudiante que no existe
CALL sp_registrar_matricula(999, 1, @msg);
SELECT @msg AS Resultado;

-- curso que no existe
CALL sp_registrar_matricula(1030281186, 99, @msg);
SELECT @msg AS Resultado;

-- parametro nulo
CALL sp_registrar_matricula(NULL, 1, @msg);
SELECT @msg AS Resultado;

-- matricula duplicada (Juan Gamez ya esta en el grupo 1)
CALL sp_registrar_matricula(1031422990, 1, @msg);
SELECT @msg AS Resultado;

-- curso sin cupo: baja el cupo del grupo 2 temporalmente
UPDATE Grupo SET Cupo = 3 WHERE IdGrupo = 2;                -- ya tiene 3 inscritos
CALL sp_registrar_matricula(1030281186, 2, @msg);
SELECT @msg AS Resultado;
UPDATE Grupo SET Cupo = 25 WHERE IdGrupo = 2;               -- restaura el cupo original

-- 5. ESTADO DESPUES DE LAS PRUEBAS (captura)
-- solo deben aparecer las 2 matriculas validas nuevas
SELECT  m.IdMatricula,
        CONCAT(e.PrimerNombre, ' ', e.PrimerApellido) AS Estudiante,
        ma.NombreMateria AS Curso,
        m.FechaMatricula,
        m.NotaFinal,
        m.ValorMatricula
FROM Matricula m
JOIN Estudiante e  ON e.IdEstudiante = m.IdEstudiante
JOIN Grupo g       ON g.IdGrupo      = m.IdGrupo
JOIN Materia ma    ON ma.IdMateria   = g.IdMateria
ORDER BY m.IdMatricula;
