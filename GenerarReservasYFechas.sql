DECLARE @cantidadFechas INT;
DECLARE @cantidadReservas INT = 20;

DECLARE @Id_propiedad INT;
DECLARE @Fecha_efectuada DATE;

WHILE (@cantidadReservas > 0)
BEGIN
	
	SET @Id_propiedad = (
		SELECT TOP 1 Id_propiedad
		FROM Propiedad
		ORDER BY NEWID()
	)
	
	INSERT INTO Reserva (Id_propiedad, Id_usuario, Fecha_efectuada)
	VALUES (
		@Id_propiedad,
		@cantidadReservas,
		DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE())
	)

	SET @cantidadReservas -= 1;

END;
-- incompleto
-- agregando comentario