DECLARE @primerAnio INT = 2023
DECLARE @segundoAnio INT = 2024


WITH Cant_dias_primer_anio AS (
	SELECT r.Id_propiedad, COUNT(f.Fecha) AS cant_dias
	FROM Reserva r
	INNER JOIN Fecha_reservada f
	ON r.Id_reserva = f.Id_reserva
	WHERE YEAR(f.Fecha) = @primerAnio
	GROUP BY r.Id_propiedad
),
UNION ALL
SELECT r.Id_propiedad, COUNT(f.Fecha) AS cant_dias
FROM Reserva r
INNER JOIN Fecha_reservada f
ON r.Id_reserva = f.Id_reserva
WHERE YEAR(f.Fecha) = @segundoAnio
GROUP BY r.Id_propiedad

