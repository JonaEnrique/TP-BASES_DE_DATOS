-- si ejecutan esto mas de una vez sin limpiar el identity de Reserva se rompe pero no tira error
-- si lo quieren correr de nuevo hagan DELETE de Fecha_reservada y Reserva
-- esto es para resetear el identity de Reserva
-- DBCC CHECKIDENT (Reserva, RESEED, 0)

DECLARE @cantidadFechas INT;
DECLARE @cantidadReservas INT = 20;

DECLARE @Id_propiedad INT;
DECLARE @Fecha_efectuada DATE;
DECLARE @Noches_minimas INT;
DECLARE @Fecha_reservada DATE
DECLARE @Id_reserva INT = 1;

-- cantidad de reservas a generar
WHILE (@cantidadReservas > 0)
BEGIN
	
	-- elige un id de propiedad random
	SET @Id_propiedad = (
		SELECT TOP 1 Id_propiedad
		FROM Propiedad
		ORDER BY NEWID()
	)

	-- la fecha de hoy menos 0 a 365 dias
	SET @Fecha_efectuada = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());
	
	-- inserta la reserva
	INSERT INTO Reserva (Id_propiedad, Id_usuario, Fecha_efectuada)
	VALUES (@Id_propiedad, @cantidadReservas, @Fecha_efectuada);

	-- saca las noches minimas de la propiedad reservada
	SET @Noches_minimas = (
		SELECT TOP 1 Noches_minimas
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

	-- disminuye y aumenta para el while y para el id de reserva
	SET @cantidadReservas -= 1;
	SET @Id_reserva += 1;

END;