USE Guia_5;

-- Nota inválida (5.5). Debe abortar con error:
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
        999,
        1031422990,
        2,
        CURDATE(),
        5.5,
        950000
    );