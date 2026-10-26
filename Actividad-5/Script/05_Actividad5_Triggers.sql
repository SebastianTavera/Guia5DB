-- Actividad 5: trigger de validacion de nota y trigger de auditoria

USE Guia_5;

-- 1. TABLA DE AUDITORIA
CREATE TABLE IF NOT EXISTS AuditoriaMatricula (
    IdAuditoria  INT AUTO_INCREMENT PRIMARY KEY,
    IdMatricula  INT          NOT NULL,
    Accion       ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    Usuario      VARCHAR(100) NOT NULL,
    FechaHora    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Detalle      VARCHAR(255)
);

-- 2. BEFORE INSERT: valida la nota
DROP TRIGGER IF EXISTS trg_validar_nota;

DELIMITER //
CREATE TRIGGER trg_validar_nota
BEFORE INSERT ON Matricula
FOR EACH ROW
BEGIN
    -- fuera de 0.0 - 5.0 cancela el INSERT
    IF NEW.NotaFinal IS NOT NULL AND (NEW.NotaFinal < 0 OR NEW.NotaFinal > 5.0) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: la nota final debe estar entre 0.0 y 5.0';
    END IF;
END //
DELIMITER ;

-- 3. AFTER INSERT: registra en auditoria
DROP TRIGGER IF EXISTS trg_auditoria_matricula;

DELIMITER //
CREATE TRIGGER trg_auditoria_matricula
AFTER INSERT ON Matricula
FOR EACH ROW
BEGIN
    -- guarda quien, cuando y que se inserto
    INSERT INTO AuditoriaMatricula (IdMatricula, Accion, Usuario, FechaHora, Detalle)
    VALUES (NEW.IdMatricula, 'INSERT', USER(), NOW(),
            CONCAT('Estudiante ', NEW.IdEstudiante, ', curso ', NEW.IdGrupo,
                   ', nota ', IFNULL(NEW.NotaFinal, 'pendiente')));
END //
DELIMITER ;

-- 4. SP DE PRUEBA: atrapa el error del trigger sin detener el script
DROP PROCEDURE IF EXISTS sp_probar_nota;

DELIMITER //
CREATE PROCEDURE sp_probar_nota(
    IN  p_IdEstudiante INT,
    IN  p_IdGrupo      INT,
    IN  p_Nota         DECIMAL(4,2),
    OUT p_Mensaje      VARCHAR(200)
)
BEGIN
    DECLARE v_NuevoId  INT;
    DECLARE v_ErrorSQL VARCHAR(200);

    -- recibe el SIGNAL del trigger
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_ErrorSQL = MESSAGE_TEXT;
        SET p_Mensaje = CONCAT('RECHAZADA (nota ', p_Nota, '): ', v_ErrorSQL);
    END;

    SELECT COALESCE(MAX(IdMatricula), 0) + 1 INTO v_NuevoId FROM Matricula;

    INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula)
    VALUES (v_NuevoId, p_IdEstudiante, p_IdGrupo, CURDATE(), p_Nota, 950000);

    SET p_Mensaje = CONCAT('ACEPTADA: matricula ', v_NuevoId, ' con nota ', p_Nota);
END //
DELIMITER ;

-- 5. AUDITORIA ANTES (captura)
SELECT COUNT(*) AS RegistrosAuditoria FROM AuditoriaMatricula;

-- 6. PRUEBAS

-- valida
CALL sp_probar_nota(1011765342, 5, 4.9, @msg);
SELECT @msg AS Resultado;

-- valida en el limite
CALL sp_probar_nota(1030281186, 5, 0.0, @msg);
SELECT @msg AS Resultado;

-- invalida: mayor a 5.0
CALL sp_probar_nota(1122151498, 5, 5.5, @msg);
SELECT @msg AS Resultado;

-- invalida: negativa
CALL sp_probar_nota(1122151498, 5, -1, @msg);
SELECT @msg AS Resultado;

-- el SP de la Actividad 1 tambien queda auditado
CALL sp_registrar_matricula(1122151498, 3, @msg);
SELECT @msg AS Resultado;

-- 7. EVIDENCIA (captura)
SELECT IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal
FROM Matricula
ORDER BY IdMatricula DESC
LIMIT 5;

-- solo los INSERT aceptados quedan auditados
SELECT * FROM AuditoriaMatricula ORDER BY IdAuditoria;

SHOW TRIGGERS LIKE 'Matricula';
