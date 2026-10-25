USE Guia_5;

-- Nota válida (4.9). Debe insertarse sin problemas:
INSERT INTO
    Matricula (
        IdMatricula,
        IdEstudiante,
        IdGrupo,
        FechaMatricula,
        NotaFinal,
        ValorMatricula
    )
VALUES (
        201,
        1031422990,
        2,
        CURDATE(),
        4.9,
        950000
    );

-- Consultar la auditoría disparada automáticamente:
SELECT * FROM AuditoriaMatricula;