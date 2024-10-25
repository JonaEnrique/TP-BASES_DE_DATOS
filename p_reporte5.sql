CREATE OR ALTER PROCEDURE p_reporte5
	@anio INT,
	@propiedad_anio INT OUTPUT,
	@propiedad_anio_anterior INT OUTPUT
AS 
BEGIN
	DECLARE @resultado TABLE (Id_propiedad INT, cant_dias INT, Anio INT)

	INSERT INTO @resultado
	SELECT c1.Id_propiedad, c1.cant_dias, (@anio - 1) AS Anio
	FROM (
		SELECT r.Id_propiedad, COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = (@anio - 1)
		GROUP BY r.Id_propiedad
	) c1
	WHERE c1.cant_dias >= ALL (
		SELECT COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = (@anio - 1)
		GROUP BY r.Id_propiedad
	)
	UNION
	SELECT c2.Id_propiedad, c2.cant_dias, @anio AS Anio
	FROM (
		SELECT r.Id_propiedad, COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = @anio
		GROUP BY r.Id_propiedad
	) c2
	WHERE c2.cant_dias >= ALL (
		SELECT COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = @anio
		GROUP BY r.Id_propiedad
	)

	SET @propiedad_anio = (
		SELECT Id_propiedad
		FROM @resultado
		WHERE Anio = @anio
	)
	SET @propiedad_anio_anterior = (
		SELECT Id_propiedad
		FROM @resultado
		WHERE Anio = (@anio - 1)
	)
END

DECLARE @actual INT
DECLARE @anterior INT

EXEC p_reporte5 @anio = 2024, @propiedad_anio = @actual OUTPUT, @propiedad_anio_anterior = @anterior OUTPUT

PRINT ('anio pedido: ' + CAST(@actual AS CHAR))
PRINT ('anio anterior: ' + CAST(@anterior AS CHAR))

