CALL sp_actualizar_estado_curso (1);

-- CONSULTA PARA LA CAPTURA "DESPUÉS":
SELECT
    IdMatricula,
    IdEstudiante,
    IdGrupo,
    NotaFinal,
    Estado
FROM Matricula
WHERE
    IdGrupo = 1;