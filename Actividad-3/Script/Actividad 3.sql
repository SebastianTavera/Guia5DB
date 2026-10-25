-- =============================================================================
-- GUÍA 5: PRÁCTICA DE BASE DE DATOS
-- ACTIVIDAD 3: FUNCIONES DEFINIDAS POR EL USUARIO (UDF)
-- =============================================================================

USE Guia_5;

-- -----------------------------------------------------------------------------
-- 1. Función para calcular la edad a partir de la fecha de nacimiento
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calcular_edad;

DELIMITER /
/

CREATE FUNCTION fn_calcular_edad(p_fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_edad INT;
    
    IF p_fecha_nacimiento IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Calcula los años completos transcurridos hasta la fecha actual
    SET v_edad = TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
    
    RETURN v_edad;
END
/
/

DELIMITER;

-- -----------------------------------------------------------------------------
-- 2. Función para formatear el nombre completo: APELLIDOS, NOMBRES en mayúsculas
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_formatear_nombre_completo;

DELIMITER /
/

CREATE FUNCTION fn_formatear_nombre_completo(
    p_primer_nombre VARCHAR(50),
    p_segundo_nombre VARCHAR(50),
    p_primer_apellido VARCHAR(50),
    p_segundo_apellido VARCHAR(50)
)
RETURNS VARCHAR(200)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_apellidos VARCHAR(100);
    DECLARE v_nombres VARCHAR(100);
    DECLARE v_resultado VARCHAR(200);
    
    -- Concatena apellidos y nombres manejando valores NULL
    SET v_apellidos = CONCAT_WS(' ', p_primer_apellido, NULLIF(TRIM(p_segundo_apellido), ''));
    SET v_nombres   = CONCAT_WS(' ', p_primer_nombre, NULLIF(TRIM(p_segundo_nombre), ''));
    
    -- Formato final: APELLIDOS, NOMBRES (todo en mayúsculas)
    SET v_resultado = UPPER(CONCAT(v_apellidos, ', ', v_nombres));
    
    RETURN v_resultado;
END
/
/

DELIMITER;

-- -----------------------------------------------------------------------------
-- 3. Demostración y pruebas mediante consulta SELECT
-- -----------------------------------------------------------------------------
SELECT
    IdEstudiante,
    fn_formatear_nombre_completo (
        PrimerNombre,
        SegundoNombre,
        PrimerApellido,
        SegundoApellido
    ) AS Estudiante_Formateado,
    FechaNacimiento,
    fn_calcular_edad (FechaNacimiento) AS Edad_Actual
FROM Estudiante;