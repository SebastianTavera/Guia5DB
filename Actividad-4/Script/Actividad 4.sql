-- =============================================================================
-- GUÍA 5: PRÁCTICA DE BASE DE DATOS
-- ACTIVIDAD 4: PROCEDIMIENTO ALMACENADO CON CURSOR
-- =============================================================================

USE Guia_5;

-- -----------------------------------------------------------------------------
-- 1. PREPARACIÓN: Agregar columna Estado a Matricula si no existe
-- -----------------------------------------------------------------------------
ALTER TABLE Matricula
ADD COLUMN IF NOT EXISTS Estado VARCHAR(20) NOT NULL DEFAULT 'Sin evaluar';

-- -----------------------------------------------------------------------------
-- 2. PROCEDIMIENTO CON CURSOR: Evaluar y actualizar estudiantes de un curso
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_actualizar_estado_curso;

DELIMITER /
/

CREATE PROCEDURE sp_actualizar_estado_curso(IN p_IdGrupo INT)
BEGIN
    -- Variables para almacenar los datos fila por fila del cursor
    DECLARE v_IdMatricula INT;
    DECLARE v_NotaFinal   DECIMAL(3,2);
    DECLARE v_NuevoEstado VARCHAR(20);
    DECLARE v_Contador    INT DEFAULT 0;
    
    -- Bandera de finalización del cursor
    DECLARE v_Fin INT DEFAULT 0;

    -- Declaración del cursor sobre las matrículas del grupo especificado
    DECLARE cur_estudiantes CURSOR FOR 
        SELECT IdMatricula, NotaFinal 
        FROM Matricula 
        WHERE IdGrupo = p_IdGrupo;

    -- Manejador para cuando el cursor termine de recorrer los registros
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Fin = 1;

    -- Valida que el grupo exista
    IF NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = p_IdGrupo) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: El grupo o curso especificado no existe.';
    END IF;

    -- Apertura y recorrido con cursor
    OPEN cur_estudiantes;

    bucle_cursor: LOOP
        FETCH cur_estudiantes INTO v_IdMatricula, v_NotaFinal;

        IF v_Fin = 1 THEN
            LEAVE bucle_cursor;
        END IF;

        -- Regla de negocio: >= 3.0 Aprobado, < 3.0 Reprobado
        IF v_NotaFinal IS NULL THEN
            SET v_NuevoEstado = 'Sin calificar';
        ELSEIF v_NotaFinal >= 3.0 THEN
            SET v_NuevoEstado = 'Aprobado';
        ELSE
            SET v_NuevoEstado = 'Reprobado';
        END IF;

        -- Actualización fila por fila mediante la clave primaria leída por el cursor
        UPDATE Matricula 
        SET Estado = v_NuevoEstado 
        WHERE IdMatricula = v_IdMatricula;

        SET v_Contador = v_Contador + 1;
    END LOOP bucle_cursor;

    CLOSE cur_estudiantes;

    -- Retorna resultado informativo de la ejecución
    SELECT CONCAT('Se actualizaron con éxito ', v_Contador, ' estudiante(s) en el grupo ', p_IdGrupo) AS Resultado;
END
/
/

DELIMITER;