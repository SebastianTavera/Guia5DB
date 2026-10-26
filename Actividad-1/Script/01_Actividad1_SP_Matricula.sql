-- Actividad 1: SP de matricula con mensaje OUT

USE Guia_5;

-- 1. CREACION DEL SP
DROP PROCEDURE IF EXISTS sp_registrar_matricula;

DELIMITER //
CREATE PROCEDURE sp_registrar_matricula(
    IN  p_IdEstudiante INT,
    IN  p_IdGrupo      INT,
    OUT p_Mensaje      VARCHAR(200)   -- exito o error
)
BEGIN
    DECLARE v_NuevoId   INT;
    DECLARE v_Cupo      INT;
    DECLARE v_Inscritos INT;
    DECLARE v_Creditos  INT;
    DECLARE v_ErrorSQL  VARCHAR(200);

    -- error SQL: deshace y lo devuelve
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_ErrorSQL = MESSAGE_TEXT;
        ROLLBACK;
        SET p_Mensaje = CONCAT('ERROR SQL: ', v_ErrorSQL);
    END;

    -- validaciones
    IF p_IdEstudiante IS NULL OR p_IdGrupo IS NULL THEN
        SET p_Mensaje = 'ERROR: estudiante y curso son obligatorios';

    ELSEIF NOT EXISTS (SELECT 1 FROM Estudiante WHERE IdEstudiante = p_IdEstudiante) THEN
        SET p_Mensaje = CONCAT('ERROR: el estudiante ', p_IdEstudiante, ' no existe');

    ELSEIF NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = p_IdGrupo) THEN
        SET p_Mensaje = CONCAT('ERROR: el curso ', p_IdGrupo, ' no existe');

    ELSEIF EXISTS (SELECT 1 FROM Matricula
                   WHERE IdEstudiante = p_IdEstudiante AND IdGrupo = p_IdGrupo) THEN
        SET p_Mensaje = 'ERROR: el estudiante ya esta matriculado en ese curso';

    ELSE
        START TRANSACTION;

        -- bloquea el grupo y revisa el cupo (NULL = ilimitado)
        SELECT Cupo INTO v_Cupo FROM Grupo WHERE IdGrupo = p_IdGrupo FOR UPDATE;
        SELECT COUNT(*) INTO v_Inscritos FROM Matricula WHERE IdGrupo = p_IdGrupo;

        IF v_Cupo IS NOT NULL AND v_Inscritos >= v_Cupo THEN
            ROLLBACK;
            SET p_Mensaje = CONCAT('ERROR: el curso ', p_IdGrupo, ' no tiene cupo (',
                                   v_Inscritos, '/', v_Cupo, ')');
        ELSE
            -- siguiente id (no es AUTO_INCREMENT)
            SELECT COALESCE(MAX(IdMatricula), 0) + 1 INTO v_NuevoId FROM Matricula;

            SELECT m.CreditosMateria INTO v_Creditos
            FROM Grupo g JOIN Materia m ON m.IdMateria = g.IdMateria
            WHERE g.IdGrupo = p_IdGrupo;

            -- crea la matricula: valor = 200.000 + 250.000 por credito
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

-- 2. ANTES (captura)
SELECT * FROM Matricula ORDER BY IdMatricula;

-- 3. PRUEBAS VALIDAS
CALL sp_registrar_matricula(1030281186, 1, @msg);
SELECT @msg AS Resultado;

CALL sp_registrar_matricula(1028886975, 3, @msg);
SELECT @msg AS Resultado;

-- 4. PRUEBAS INVALIDAS

-- estudiante no existe
CALL sp_registrar_matricula(999, 1, @msg);
SELECT @msg AS Resultado;

-- curso no existe
CALL sp_registrar_matricula(1030281186, 99, @msg);
SELECT @msg AS Resultado;

-- parametro nulo
CALL sp_registrar_matricula(NULL, 1, @msg);
SELECT @msg AS Resultado;

-- ya matriculado
CALL sp_registrar_matricula(1031422990, 1, @msg);
SELECT @msg AS Resultado;

-- sin cupo: baja el cupo y luego lo restaura
UPDATE Grupo SET Cupo = 3 WHERE IdGrupo = 2;
CALL sp_registrar_matricula(1030281186, 2, @msg);
SELECT @msg AS Resultado;
UPDATE Grupo SET Cupo = 25 WHERE IdGrupo = 2;

-- 5. DESPUES (captura): solo 2 matriculas nuevas
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
