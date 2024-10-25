CREATE VIEW Dias_Ocupados_Anuales AS
SELECT 
    r.Id_propiedad,
    YEAR(f.Fecha) AS Año,
    COUNT(DISTINCT f.Fecha) AS Dias_Ocupados
FROM 
    Reserva r JOIN Fecha_reservada f ON r.Id_reserva = f.Id_reserva
GROUP BY 
    r.Id_propiedad, 
    YEAR(f.Fecha);

GO
SELECT 
    D.Dias_Ocupados, D.Id_propiedad 
FROM 
    Dias_Ocupados_Anuales D
WHERE 
    Año = 2024;
    

