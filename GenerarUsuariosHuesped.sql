DECLARE @cantidad INT = 100;

DECLARE @Nombre NVARCHAR(100) = 'Nombre';
DECLARE @Contrasenia NVARCHAR(20) = 'P@ssW0rd'

DECLARE @cantidadUsuarios INT = 50;
DECLARE @Id_usuario INT;

CREATE TABLE #Usuarios_random (Id_usuarios INT)

INSERT INTO #Usuarios_random (Id_usuarios)
SELECT TOP (@cantidadUsuarios) Id_usuario
FROM Usuario
ORDER BY NEWID();



WHILE (@cantidad > 0)
BEGIN
	IF(@cantidad%2 = 0) 
	BEGIN
		SET @Id_usuario = (
			SELECT TOP 1 Id_usuarios
			FROM #Usuarios_random
			ORDER BY Id_usuarios
		);
		DELETE FROM #Usuarios_random
		WHERE Id_usuarios = @Id_usuario;
	END 
	ELSE
		BEGIN
			SET @Id_usuario = null;
		END


	INSERT INTO dbo.Usuario(Id_usuario, Nombre, Contrasenia, Id_categoria, Id_usuario_referente)
	VALUES (
		@cantidad,
		@Nombre + CAST(@cantidad AS CHAR),
		@Contrasenia + CAST(@cantidad AS CHAR),
		NULL,
		@Id_usuario
	)

	SET @cantidad -= 1;

END

select Id_usuario_referente
from Usuario