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

WHILE (@cantidadReservas > 0)
BEGIN
	
	SET @Id_propiedad = (
		SELECT TOP 1 Id_propiedad
		FROM Propiedad
		ORDER BY NEWID()
	)

	SET @Fecha_efectuada = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());
	
	INSERT INTO Reserva (Id_propiedad, Id_usuario, Fecha_efectuada)
	VALUES (
		@Id_propiedad,
		@cantidadReservas,
		@Fecha_efectuada
	);

	SET @Noches_minimas = (
		SELECT TOP 1 Noches_minimas
		FROM Propiedad
		WHERE Id_propiedad = @Id_propiedad
	);

	SET @Fecha_reservada = DATEADD(DAY, FLOOR(RAND() * 30), @Fecha_efectuada);

	WHILE (@Noches_minimas > 0)
	BEGIN

		INSERT INTO Fecha_reservada (Id_reserva, Fecha)
		VALUES (@Id_reserva, @Fecha_reservada);

		SET @Fecha_reservada = DATEADD(DAY, 1, @Fecha_reservada);

		SET @Noches_minimas -= 1;

	END;

	SET @cantidadReservas -= 1;
	SET @Id_reserva += 1;

END;