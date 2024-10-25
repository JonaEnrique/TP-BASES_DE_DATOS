-- si ejecutan esto mas de una vez sin limpiar el identity de Reserva se rompe pero no tira error
-- si lo quieren correr de nuevo hagan DELETE de Fecha_reservada y Reserva
-- esto es para resetear el identity de Reserva
-- DBCC CHECKIDENT (Reserva, RESEED, 0)
delete from Fecha_reservada
delete from Reserva

DECLARE @cantidadFechas INT;
DECLARE @cantidadPropiedades INT = 20;

DECLARE @Id_propiedad INT;
DECLARE @Fecha_efectuada DATE;
DECLARE @Noches_minimas INT;
DECLARE @Fecha_reservada DATE
DECLARE @Id_reserva INT = 1;
DECLARE @cantidadReservas INT;


-- creo una tabla temporal
CREATE TABLE #Propiedades_random (Id_propiedad INT)
	
-- la lleno con @cantidadReservas ids de propiedad random
INSERT INTO #Propiedades_random (Id_propiedad)
SELECT TOP (@cantidadPropiedades) Id_propiedad
FROM Propiedad
ORDER BY NEWID(); --hace que ordene de forma random los ID de propiedad

-- cantidad de reservas a generar
WHILE (@cantidadPropiedades > 0)
BEGIN
	-- asigno el primero a la variable
	SET @Id_propiedad = (
		SELECT TOP 1 Id_propiedad
		FROM #Propiedades_random
		ORDER BY Id_propiedad
	);

	-- borro la que use de la tabla
	DELETE FROM #Propiedades_random
	WHERE Id_propiedad = @Id_propiedad;

	-- la fecha de hoy menos 0 a 365 dias
	SET @Fecha_efectuada = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());

	-- entre 1 y 3 reservas en la misma propiedad
	SET @cantidadReservas = 1 + FLOOR(RAND() * 2)
	
	-- mientras haya reservas por hacer
	WHILE (@cantidadReservas > 0)
	BEGIN
		-- inserta una reserva con un huesped random
		INSERT INTO Reserva (Id_propiedad, Id_usuario, Fecha_efectuada)
		VALUES (@Id_propiedad, 1 + FLOOR(RAND() * 99), @Fecha_efectuada);

		-- saca las noches minimas de la propiedad reservada
		SET @Noches_minimas = (
			SELECT Noches_minimas
			FROM Propiedad
			WHERE Id_propiedad = @Id_propiedad
		);

		-- establece la reservada mas 1 a 31 dias como primera fecha
		SET @Fecha_reservada = DATEADD(DAY, 1 + FLOOR(RAND() * 30), @Fecha_efectuada);

		-- hace tantas fechas como noches minimas acepta la propiedad
		WHILE (@Noches_minimas > 0)
		BEGIN

			-- inserta la fecha 
			INSERT INTO Fecha_reservada (Id_reserva, Fecha)
			VALUES (@Id_reserva, @Fecha_reservada);

			-- le suma uno a la fecha
			SET @Fecha_reservada = DATEADD(DAY, 1, @Fecha_reservada);

			-- disminuye las noches para el while
			SET @Noches_minimas -= 1;

		END;

		-- setea la fecha efectuada a la ultima fecha reservada para que no se pisen las reservas
		SET @Fecha_efectuada = @Fecha_reservada
		SET @CantidadReservas -= 1;

	END;

	-- disminuye y aumenta para el while y para el id de reserva
	SET @cantidadPropiedades -= 1;
	SET @Id_reserva += 1;

END;
-- dropeo la tabla temporal
DROP TABLE #Propiedades_random;

--cantidad de reservas por propiedad

SELECT Id_propiedad, COUNT(*) AS CantidadReservas
FROM Reserva
GROUP BY Id_propiedad;
/*
delete from Fecha_reservada
delete from Reserva
*/ 
