-- Actividad 5: prueba rechazada (falla a proposito con ERROR 1644)

USE Guia_5;

-- auditoria antes del intento
SELECT COUNT(*) AS RegistrosAuditoria FROM AuditoriaMatricula;

-- nota 5.5: el trigger cancela el INSERT
INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula)
VALUES (9999, 1031422990, 2, CURDATE(), 5.5, 950000);
