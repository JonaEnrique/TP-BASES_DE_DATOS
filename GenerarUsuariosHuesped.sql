DECLARE @cantidad INT = 100;

DECLARE @Nombre NVARCHAR(100) = 'Nombre';
DECLARE @Contrasenia NVARCHAR(20) = 'P@ssW0rd'

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