DECLARE @cantidad INT = 100;

DECLARE @Nombre NVARCHAR(100) = 'noMbRe uSr';
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
	DROP TABLE #Usuarios_random

---------------------------------------------------------
GO
DECLARE @cantidad INT = 100;
CREATE TABLE #Usuarios_referentes (Id_usuario INT);

-- Insertar la mitad de los usuarios con referente en la tabla temporal
INSERT INTO #Usuarios_referentes (Id_usuario)
SELECT TOP (@cantidad / 2) Id_usuario
FROM Usuario
WHERE Id_usuario_referente IS NOT NULL
ORDER BY NEWID();

-- Actualizar los usuarios sin referente
WHILE (@cantidad > 0 AND EXISTS (SELECT 1 FROM Usuario WHERE Id_usuario_referente IS NULL))
BEGIN
    DECLARE @referenteId INT;

    -- Seleccionar un Id_usuario aleatorio de la tabla temporal y guardarlo en @referenteId
    SELECT TOP 1 @referenteId = Id_usuario FROM #Usuarios_referentes ORDER BY NEWID();

    -- Actualizar un usuario sin referente asignándole el referente seleccionado
    UPDATE TOP (1) Usuario
    SET Id_usuario_referente = @referenteId
    WHERE Id_usuario_referente IS NULL;

    -- Eliminar el referente utilizado para no reutilizarlo
    DELETE FROM #Usuarios_referentes WHERE Id_usuario = @referenteId;

    SET @cantidad -= 1;
END;

-- Eliminar la tabla temporal
DROP TABLE #Usuarios_referentes;



select *
from Usuario
where Id_usuario_referente is not null
/*
*/

--delete
--from Reserva

--delete
--from Fecha_reservada