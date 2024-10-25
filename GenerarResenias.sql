--Reseña(Id_reseña, Comentario, Calificación, Fecha_creada, Id_propiedad, Id_usuario)

CREATE TABLE #Propiedades_random (Id_propiedad INT);
CREATE TABLE #Usuarios_random (Id_usuario INT);

DECLARE @cantidadResenias INT = 20;
DECLARE @comentario NVARCHAR(1000);
DECLARE @calificacion TINYINT;
DECLARE @fechaCreada DATE;
DECLARE @idPropiedad INT;
DECLARE @idUsuario INT;

---------------------------------------------------
INSERT INTO #Propiedades_random (Id_propiedad)
SELECT TOP (@cantidadResenias) Id_propiedad
FROM Propiedad
ORDER BY NEWID();

INSERT INTO #Usuarios_random (Id_usuario)
SELECT TOP (@cantidadResenias) Id_usuario
FROM Usuario
ORDER BY NEWID();

SELECT *
FROM #Propiedades_random

SELECT *
FROM #Usuarios_random
---------------------------------------------------
GO

DECLARE @cantidadResenias INT = 20;
DECLARE @comentario NVARCHAR(1000);
DECLARE @calificacion TINYINT;
DECLARE @fechaCreada DATE;
DECLARE @idPropiedad INT;
DECLARE @idUsuario INT;

WHILE(@cantidadResenias > 0)
BEGIN
	SET @fechaCreada = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());
	SET @comentario = CONCAT('Comentario', @cantidadResenias);
	SET @calificacion =  1 + FLOOR(RAND() * 4);-- 1 a 5

	SET @idPropiedad = (
		SELECT TOP 1 Id_propiedad
		FROM #Propiedades_random
		ORDER BY Id_propiedad
	);

	DELETE FROM #Propiedades_random
	WHERE Id_propiedad = @idPropiedad;

	SET @idUsuario = (
		SELECT TOP 1 Id_usuario
		FROM #Usuarios_random
		ORDER BY Id_usuario
	);

	DELETE FROM #Usuarios_random
	WHERE Id_usuario = @idUsuario;

	INSERT INTO Resenia (Comentario, Calificacion, Fecha_creada, Id_Propiedad, Id_usuario)
	VALUES (@comentario, @calificacion, @fechaCreada, @idPropiedad, @idUsuario);

	SET @cantidadResenias -= 1;
END

DROP TABLE #Propiedades_random;
DROP TABLE #Usuarios_random;

SELECT *
FROM Resenia