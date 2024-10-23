CREATE VIEW v_vista1
AS
WITH Fechas_por_reserva AS (
	SELECT Id_reserva, COUNT(Fecha) AS Cantidad_Fechas
	FROM Fecha_reservada
	GROUP BY Id_reserva
)

SELECT TOP 10 Usuario.Id_usuario, Fechas_por_reserva.Cantidad_fechas
FROM Reserva
INNER JOIN Fechas_por_reserva
ON Reserva.Id_reserva = Fechas_por_reserva.Id_reserva
INNER JOIN Usuario
ON Reserva.Id_usuario = Usuario.Id_usuario;

-- se me hace medio simple pero es para probar

--SELECT p.Id_propiedad, l.Nombre
--FROM Propiedad AS p
--INNER JOIN Localidad AS l
--ON p.CP = l.CP 