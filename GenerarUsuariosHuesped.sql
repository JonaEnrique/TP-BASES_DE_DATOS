DECLARE @cantidad INT = 100;

DECLARE @Nombre VARCHAR(100) = 'Nombre';
DECLARE @Contrasenia VARCHAR(20) = 'P@ssW0rd'

WHILE (@cantidad > 0)
BEGIN
	
	INSERT INTO Usuario(Id_usuario, Nombre, Contrasenia, Id_categoria)
	VALUES (
		@cantidad,
		@Nombre + CAST(@cantidad AS CHAR),
		@Contrasenia + CAST(@cantidad AS CHAR),
		NULL
	)

	SET @cantidad -= 1;

END