-- =============================================================================
-- GUÍA 5: PRÁCTICA DE BASE DE DATOS
-- ACTIVIDAD 5: INTEGRACIÓN CON TRIGGERS (VALIDACIÓN Y AUDITORÍA)
-- =============================================================================

USE Guia_5;

-- -----------------------------------------------------------------------------
-- 1. ESTRUCTURA: Tabla de Auditoría para Matrículas
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AuditoriaMatricula (
    IdAuditoria INT AUTO_INCREMENT PRIMARY KEY,
    IdMatricula INT NOT NULL,
    Accion VARCHAR(20) NOT NULL,
    Usuario VARCHAR(100) NOT NULL,
    FechaHora DATETIME NOT NULL,
    Detalle VARCHAR(255)
);

-- -----------------------------------------------------------------------------
-- 2. TRIGGER BEFORE INSERT: Validación de Rango de Nota (0.0 a 5.0)
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_validar_nota_matricula;

DELIMITER / /

CREATE TRIGGER tg_validar_nota_matricula
BEFORE INSERT ON Matricula
FOR EACH ROW
BEGIN
    -- Valida que la nota final esté en la escala permitida
    IF NEW.NotaFinal IS NOT NULL AND (NEW.NotaFinal < 0.0 OR NEW.NotaFinal > 5.0) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: La nota final debe estar comprendida entre 0.0 y 5.0.';
    END IF;
END //

DELIMITER;

-- -----------------------------------------------------------------------------
-- 3. TRIGGER AFTER INSERT: Registro automático de Auditoría
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_auditar_matricula;

DELIMITER / /

CREATE TRIGGER tg_auditar_matricula
AFTER INSERT ON Matricula
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaMatricula (
        IdMatricula,
        Accion,
        Usuario,
        FechaHora,
        Detalle
    ) VALUES (
        NEW.IdMatricula,
        'INSERT',
        CURRENT_USER(),
        NOW(),
        CONCAT('Matrícula registrada. Estudiante: ', NEW.IdEstudiante, ', Grupo: ', NEW.IdGrupo, ', Nota: ', IFNULL(NEW.NotaFinal, 'Sin nota'))
    );
END //

DELIMITER;