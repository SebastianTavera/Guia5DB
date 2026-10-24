-- Practica 5 - Tarea previa (Aula Invertida)
-- Sistema: Guia_5
-- Nota: en este esquema el "curso" es la tabla Grupo (IdGrupo)
-- Compatible: MySQL 8.x y MariaDB 10.5+

USE Guia_5;

-- PUNTO 1. PARAMETROS IN, OUT e INOUT

-- IN: el valor entra al SP y solo se lee
DROP PROCEDURE IF EXISTS sp_ejemplo_in;
DELIMITER //
CREATE PROCEDURE sp_ejemplo_in(IN p_IdEstudiante INT)
BEGIN
    -- muestra los datos del estudiante recibido
    SELECT IdEstudiante, PrimerNombre, PrimerApellido
    FROM Estudiante
    WHERE IdEstudiante = p_IdEstudiante;
END //
DELIMITER ;

-- OUT: el SP escribe un valor que lee quien lo llama
DROP PROCEDURE IF EXISTS sp_ejemplo_out;
DELIMITER //
CREATE PROCEDURE sp_ejemplo_out(OUT p_Total INT)
BEGIN
    -- guarda el total de estudiantes en la variable de salida
    SELECT COUNT(*) INTO p_Total FROM Estudiante;
END //
DELIMITER ;

-- INOUT: entra con un valor, el SP lo modifica y sale cambiado
DROP PROCEDURE IF EXISTS sp_ejemplo_inout;
DELIMITER //
CREATE PROCEDURE sp_ejemplo_inout(INOUT p_Valor INT)
BEGIN
    -- aplica un 10% de descuento sobre el valor recibido
    SET p_Valor = p_Valor * 0.9;
END //
DELIMITER ;

-- Pruebas de los tres tipos
CALL sp_ejemplo_in(1031422990);         -- IN: devuelve a Juan Gamez

CALL sp_ejemplo_out(@total);            -- OUT: llena @total
SELECT @total AS TotalEstudiantes;      -- 5

SET @valor = 1200000;                   -- INOUT: valor inicial
CALL sp_ejemplo_inout(@valor);
SELECT @valor AS ValorConDescuento;     -- 1080000

-- PUNTO 2. CURSORES (respuesta, max. 100 palabras)
-- Un cursor es necesario cuando hay que procesar fila por fila un resultado
-- y aplicar a cada fila una logica distinta que no cabe en un solo
-- UPDATE/INSERT ... SELECT (ej. decisiones con IF, llamar otro SP por fila).
-- Desventaja principal: rendimiento. Recorre registro a registro en lugar de
-- operar por conjuntos, consume mas memoria y bloqueos, y escala mal en
-- tablas grandes. En MySQL ademas es solo lectura y solo avanza hacia adelante.

-- PUNTO 3. SP QUE REGISTRA UNA NUEVA MATRICULA (version de la tarea)
DROP PROCEDURE IF EXISTS sp_registrar_matricula_basico;
DELIMITER //
CREATE PROCEDURE sp_registrar_matricula_basico(
    IN p_IdEstudiante INT,
    IN p_IdGrupo      INT
)
BEGIN
    DECLARE v_NuevoId INT;

    -- verifica que existan el estudiante y el curso
    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE IdEstudiante = p_IdEstudiante) THEN
        SELECT 'Error: el estudiante no existe' AS Mensaje;
    ELSEIF NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = p_IdGrupo) THEN
        SELECT 'Error: el curso no existe' AS Mensaje;
    ELSE
        -- calcula el siguiente IdMatricula (la PK no es AUTO_INCREMENT)
        SELECT COALESCE(MAX(IdMatricula), 0) + 1 INTO v_NuevoId FROM Matricula;

        -- esta parte crea la matricula con la fecha actual
        INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula)
        VALUES (v_NuevoId, p_IdEstudiante, p_IdGrupo, CURDATE());

        SELECT CONCAT('Matricula ', v_NuevoId, ' registrada') AS Mensaje;
    END IF;
END //
DELIMITER ;

-- Pruebas
CALL sp_registrar_matricula_basico(1122151498, 1);   -- valido
CALL sp_registrar_matricula_basico(999, 1);          -- estudiante inexistente
CALL sp_registrar_matricula_basico(1122151498, 99);  -- curso inexistente

-- Evidencia
SELECT * FROM Matricula ORDER BY IdMatricula DESC LIMIT 3;
