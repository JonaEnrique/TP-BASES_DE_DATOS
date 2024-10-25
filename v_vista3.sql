CREATE VIEW Dias_Ocupados_Anuales AS
SELECT 
    r.Id_propiedad,
    YEAR(rf.Fecha_efectuada) AS Año,
    COUNT(DISTINCT rf.Fecha_efectuada) AS Dias_Ocupados
FROM 
    Reserva r
JOIN 
    Reserva_Fechas rf ON r.Id_reserva = rf.Id_reserva
GROUP BY 
    r.Id_propiedad, 
    YEAR(rf.Fecha_efectuada);