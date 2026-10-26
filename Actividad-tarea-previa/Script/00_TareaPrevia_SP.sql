-- Tarea previa: parametros IN/OUT/INOUT, cursores y SP basico de matricula

USE Guia_5;

-- PUNTO 1. PARAMETROS IN, OUT e INOUT

-- IN: solo entra
DROP PROCEDURE IF EXISTS sp_ejemplo_in;
DELIMITER //
CREATE PROCEDURE sp_ejemplo_in(IN p_IdEstudiante INT)
BEGIN
    SELECT IdEstudiante, PrimerNombre, PrimerApellido
    FROM Estudiante
    WHERE IdEstudiante = p_IdEstudiante;
END //
DELIMITER ;

-- OUT: el SP devuelve un valor
DROP PROCEDURE IF EXISTS sp_ejemplo_out;
DELIMITER //
CREATE PROCEDURE sp_ejemplo_out(OUT p_Total INT)
BEGIN
    SELECT COUNT(*) INTO p_Total FROM Estudiante;
END //
DELIMITER ;

-- INOUT: entra, se modifica y sale
DROP PROCEDURE IF EXISTS sp_ejemplo_inout;
DELIMITER //
CREATE PROCEDURE sp_ejemplo_inout(INOUT p_Valor INT)
BEGIN
    -- descuento del 10%
    SET p_Valor = p_Valor * 0.9;
END //
DELIMITER ;

CALL sp_ejemplo_in(1031422990);

CALL sp_ejemplo_out(@total);
SELECT @total AS TotalEstudiantes;

SET @valor = 1200000;
CALL sp_ejemplo_inout(@valor);
SELECT @valor AS ValorConDescuento;

-- PUNTO 2. CURSORES (respuesta, max. 100 palabras)
-- Un cursor es necesario cuando hay que procesar fila por fila un resultado
-- y aplicar a cada fila una logica distinta que no cabe en un solo
-- UPDATE/INSERT ... SELECT (ej. decisiones con IF, llamar otro SP por fila).
-- Desventaja principal: rendimiento. Recorre registro a registro en lugar de
-- operar por conjuntos, consume mas memoria y bloqueos, y escala mal en
-- tablas grandes. En MySQL ademas es solo lectura y solo avanza hacia adelante.

-- PUNTO 3. SP BASICO DE MATRICULA
DROP PROCEDURE IF EXISTS sp_registrar_matricula_basico;
DELIMITER //
CREATE PROCEDURE sp_registrar_matricula_basico(
    IN p_IdEstudiante INT,
    IN p_IdGrupo      INT
)
BEGIN
    DECLARE v_NuevoId INT;

    -- valida que existan estudiante y curso
    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE IdEstudiante = p_IdEstudiante) THEN
        SELECT 'Error: el estudiante no existe' AS Mensaje;
    ELSEIF NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = p_IdGrupo) THEN
        SELECT 'Error: el curso no existe' AS Mensaje;
    ELSE
        -- siguiente id (no es AUTO_INCREMENT)
        SELECT COALESCE(MAX(IdMatricula), 0) + 1 INTO v_NuevoId FROM Matricula;

        -- inserta con la fecha actual
        INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula)
        VALUES (v_NuevoId, p_IdEstudiante, p_IdGrupo, CURDATE());

        SELECT CONCAT('Matricula ', v_NuevoId, ' registrada') AS Mensaje;
    END IF;
END //
DELIMITER ;

CALL sp_registrar_matricula_basico(1122151498, 1);   -- valido
CALL sp_registrar_matricula_basico(999, 1);          -- estudiante no existe
CALL sp_registrar_matricula_basico(1122151498, 99);  -- curso no existe

SELECT * FROM Matricula ORDER BY IdMatricula DESC LIMIT 3;
