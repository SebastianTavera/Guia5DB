-- Practica 5 - Actividad 2: SP con logica de negocio compleja
-- Sistema: Guia_5
-- SP que calcula el promedio de un estudiante, lo clasifica y actualiza su estado
-- Escala: Excelente (>=4.5), Bueno (>=4.0), Aprobado (>=3.0), Reprobado (<3.0)
-- Compatible: MySQL 8.x y MariaDB 10.5+

USE Guia_5;

-- 1. PREPARACION: columnas de estado en Estudiante
-- revisa si la columna ya existe (MySQL no soporta ADD COLUMN IF NOT EXISTS)
SET @existe = (SELECT COUNT(*) FROM information_schema.COLUMNS
               WHERE TABLE_SCHEMA = DATABASE()
                 AND TABLE_NAME   = 'Estudiante'
                 AND COLUMN_NAME  = 'Promedio');

-- arma el ALTER solo si falta; si ya existe, no hace nada
SET @sql = IF(@existe = 0,
    'ALTER TABLE Estudiante
         ADD COLUMN Promedio        DECIMAL(3,2) NULL,
         ADD COLUMN EstadoAcademico VARCHAR(20)  NOT NULL DEFAULT ''Sin calificar''',
    'SELECT ''Columnas ya existen'' AS Aviso');

-- ejecuta la sentencia armada
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. DATOS DE PRUEBA para cubrir todas las clasificaciones
-- los datos base solo producen "Bueno" y "Aprobado"; se agregan 3 casos
INSERT IGNORE INTO Estudiante
    (IdEstudiante, PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido,
     CorreoEstudiante, PrefijoTelefono, Telefono, FechaNacimiento, Direccion)
VALUES
    (1000000001, 'Laura',  NULL, 'Rojas',  'Pinto', 'laurarojas@academia.umb.edu.co',  '+57', '3001112233', '2006-03-14', NULL),  -- Excelente
    (1000000002, 'Carlos', NULL, 'Mejia',  'Ruiz',  'carlosmejia@academia.umb.edu.co', '+57', '3004445566', '2005-08-02', NULL),  -- Reprobado
    (1000000003, 'Sofia',  NULL, 'Castro', 'Leon',  'sofiacastro@academia.umb.edu.co', '+57', '3007778899', '2007-01-25', NULL);  -- sin notas

INSERT IGNORE INTO Matricula VALUES
    (101, 1000000001, 1, '2026-08-03', 4.8, 1200000),
    (102, 1000000001, 2, '2026-08-03', 4.6,  950000),
    (103, 1000000002, 1, '2026-08-03', 2.5, 1200000),
    (104, 1000000002, 3, '2026-08-03', 2.9,  700000);

-- 3. CREACION DEL SP
DROP PROCEDURE IF EXISTS sp_calcular_promedio;

DELIMITER //
CREATE PROCEDURE sp_calcular_promedio(
    IN  p_IdEstudiante  INT,            -- estudiante a evaluar
    OUT p_Promedio      DECIMAL(3,2),   -- promedio calculado
    OUT p_Clasificacion VARCHAR(40)     -- clasificacion o mensaje de error
)
BEGIN
    DECLARE v_ErrorSQL VARCHAR(200);

    -- si falla cualquier sentencia SQL: deshace y devuelve el error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_ErrorSQL = MESSAGE_TEXT;
        ROLLBACK;
        SET p_Promedio = NULL;
        SET p_Clasificacion = LEFT(CONCAT('ERROR SQL: ', v_ErrorSQL), 40);
    END;

    -- valida que el estudiante exista
    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE IdEstudiante = p_IdEstudiante) THEN
        SET p_Promedio = NULL;
        SET p_Clasificacion = 'ERROR: el estudiante no existe';
    ELSE
        START TRANSACTION;

        -- calcula el promedio (AVG ignora las notas NULL)
        SELECT ROUND(AVG(NotaFinal), 2) INTO p_Promedio
        FROM Matricula
        WHERE IdEstudiante = p_IdEstudiante;

        -- clasifica segun la escala de la guia
        SET p_Clasificacion = CASE
            WHEN p_Promedio IS NULL THEN 'Sin calificar'
            WHEN p_Promedio >= 4.5  THEN 'Excelente'
            WHEN p_Promedio >= 4.0  THEN 'Bueno'
            WHEN p_Promedio >= 3.0  THEN 'Aprobado'
            ELSE                         'Reprobado'
        END;

        -- esta parte actualiza el estado del estudiante en la tabla
        UPDATE Estudiante
        SET Promedio        = p_Promedio,
            EstadoAcademico = p_Clasificacion
        WHERE IdEstudiante = p_IdEstudiante;

        COMMIT;
    END IF;
END //
DELIMITER ;

-- 4. ESTADO ANTES (captura): todos en "Sin calificar"
SELECT IdEstudiante, PrimerNombre, PrimerApellido, Promedio, EstadoAcademico
FROM Estudiante
ORDER BY IdEstudiante;

-- 5. PRUEBAS: un CALL por estudiante

-- Laura Rojas: (4.8 + 4.6) / 2 = 4.70 -> Excelente
CALL sp_calcular_promedio(1000000001, @prom, @clasif);
SELECT 1000000001 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Juan Gamez: (4.5 + 4.2 + 3.9 + 4.8 + 4.0) / 5 = 4.28 -> Bueno
CALL sp_calcular_promedio(1031422990, @prom, @clasif);
SELECT 1031422990 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Joan Romagna: (3.8 + 4.1 + 4.6) / 3 = 4.17 -> Bueno
CALL sp_calcular_promedio(1028886975, @prom, @clasif);
SELECT 1028886975 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Esteban Salvador: (3.5 + 4.0 + 4.7) / 3 = 4.07 -> Bueno
CALL sp_calcular_promedio(1011765342, @prom, @clasif);
SELECT 1011765342 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Andres Viafara: 4.3 -> Bueno
CALL sp_calcular_promedio(1122151498, @prom, @clasif);
SELECT 1122151498 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Andres Duenas: 3.7 -> Aprobado
CALL sp_calcular_promedio(1030281186, @prom, @clasif);
SELECT 1030281186 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Carlos Mejia: (2.5 + 2.9) / 2 = 2.70 -> Reprobado
CALL sp_calcular_promedio(1000000002, @prom, @clasif);
SELECT 1000000002 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- Sofia Castro: sin matriculas -> Sin calificar
CALL sp_calcular_promedio(1000000003, @prom, @clasif);
SELECT 1000000003 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- estudiante inexistente -> mensaje de error
CALL sp_calcular_promedio(999, @prom, @clasif);
SELECT 999 AS IdEstudiante, @prom AS Promedio, @clasif AS Clasificacion;

-- 6. ESTADO DESPUES (captura): estado actualizado automaticamente
SELECT  e.IdEstudiante,
        CONCAT(e.PrimerNombre, ' ', e.PrimerApellido) AS Estudiante,
        COUNT(m.NotaFinal) AS NotasRegistradas,
        e.Promedio,
        e.EstadoAcademico
FROM Estudiante e
LEFT JOIN Matricula m ON m.IdEstudiante = e.IdEstudiante
GROUP BY e.IdEstudiante, e.PrimerNombre, e.PrimerApellido, e.Promedio, e.EstadoAcademico
ORDER BY e.Promedio DESC;
