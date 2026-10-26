-- Actividad 3: funciones de edad y nombre formateado

USE Guia_5;

-- 1. FUNCION EDAD
DROP FUNCTION IF EXISTS fn_calcular_edad;

DELIMITER //
CREATE FUNCTION fn_calcular_edad(p_Fecha DATE)
RETURNS INT
NOT DETERMINISTIC   -- depende de la fecha actual
NO SQL              -- evita el error 1418
BEGIN
    IF p_Fecha IS NULL THEN
        RETURN NULL;
    END IF;

    -- anios cumplidos hasta hoy
    RETURN TIMESTAMPDIFF(YEAR, p_Fecha, CURDATE());
END //
DELIMITER ;

-- 2. FUNCION NOMBRE
DROP FUNCTION IF EXISTS fn_formatear_nombre;

DELIMITER //
CREATE FUNCTION fn_formatear_nombre(
    p_PrimerNombre    VARCHAR(50),
    p_SegundoNombre   VARCHAR(50),
    p_PrimerApellido  VARCHAR(50),
    p_SegundoApellido VARCHAR(50)
)
RETURNS VARCHAR(210)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_Apellidos VARCHAR(101);
    DECLARE v_Nombres   VARCHAR(101);

    -- une las partes y salta las vacias o NULL
    SET v_Apellidos = CONCAT_WS(' ', NULLIF(TRIM(p_PrimerApellido), ''), NULLIF(TRIM(p_SegundoApellido), ''));
    SET v_Nombres   = CONCAT_WS(' ', NULLIF(TRIM(p_PrimerNombre), ''),   NULLIF(TRIM(p_SegundoNombre), ''));

    -- "APELLIDOS, NOMBRES" en mayusculas
    RETURN UPPER(CONCAT_WS(', ', v_Apellidos, v_Nombres));
END //
DELIMITER ;

-- 3. PRUEBAS SUELTAS (captura)
SELECT fn_calcular_edad('2007-12-18')                         AS EdadJoan,
       fn_calcular_edad(NULL)                                 AS EdadNula,
       fn_formatear_nombre('Joan', 'Sebastian', 'Romagna', 'Taverna') AS NombreCompleto,
       fn_formatear_nombre('Esteban', NULL, 'Salvador', 'Guzman')     AS SinSegundoNombre;

-- 4. USO EN SELECT (captura)
SELECT  IdEstudiante,
        fn_formatear_nombre(PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido) AS Estudiante,
        FechaNacimiento,
        fn_calcular_edad(FechaNacimiento) AS Edad
FROM Estudiante
ORDER BY Estudiante;

-- 5. MISMAS FUNCIONES SOBRE PROFESOR
SELECT  IdProfesor,
        fn_formatear_nombre(PrimerNombreProfesor, SegundoNombreProfesor,
                            PrimerApellidoProfesor, SegundoApellidoProfesor) AS Profesor,
        fn_calcular_edad(FechaNacimiento) AS Edad
FROM Profesor
ORDER BY IdProfesor;

-- 6. FUNCION EN WHERE: mayores de 18
SELECT  fn_formatear_nombre(PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido) AS Estudiante,
        fn_calcular_edad(FechaNacimiento) AS Edad
FROM Estudiante
WHERE fn_calcular_edad(FechaNacimiento) >= 18
ORDER BY Edad DESC;
