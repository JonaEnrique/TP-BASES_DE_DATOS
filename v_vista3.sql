CREATE OR ALTER VIEW Cantidad_Resenias_UltimoAnio AS
SELECT 
    p.Id_usuario AS IdUsuario,
    YEAR(r.Fecha_creada) AS Anio,
    COUNT(r.Id_resenia) AS CantidadResenias
FROM 
    Resenia r
JOIN 
    Propiedad p ON r.Id_propiedad = p.Id_propiedad
WHERE 
    r.Fecha_creada >= DATEADD(YEAR, -1, GETDATE())
GROUP BY 
    p.Id_usuario,
    YEAR(r.Fecha_creada);

GO
SELECT 
    CR.IdUsuario, CR.CantidadResenias 
FROM 
    Cantidad_Resenias_UltimoAnio CR
WHERE 
    Anio = 2024;
   


