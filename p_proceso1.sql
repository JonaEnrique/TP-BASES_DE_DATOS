CREATE OR ALTER PROCEDURE p_proceso1
	@Accion CHAR,
	@Id_usuario INT,
	@Nombre NVARCHAR(100) = NULL,
	@Contrasenia NVARCHAR(20) = NULL,
	@Categoria INT = NULL
AS
BEGIN
	IF (@Accion = 'A')
	BEGIN
		IF (NOT EXISTS (SELECT 1 FROM Usuario WHERE Id_usuario = @Id_usuario))
		BEGIN
			IF (dbo.f_funcion2(@Contrasenia) = 1)
			BEGIN
				IF (@Categoria IS NULL)
				BEGIN
					INSERT INTO Usuario
					VALUES (@Id_usuario, @Nombre, @Contrasenia, @Categoria)
					
					PRINT ('Usuario nuevo agregado')
				END
				ELSE
					PRINT ('la categoria debe ser nula al crear un usuario')
			END
			ELSE
				PRINT ('contrasenia invalida')
		END
		ELSE
			PRINT ('El usuario con ID ' + CAST(@Id_usuario AS NVARCHAR(100)) + ' ya existe')
	END
	ELSE IF (@Accion = 'B')
	BEGIN
		IF (EXISTS (SELECT 1 FROM Usuario WHERE Id_usuario = @Id_usuario))
		BEGIN
			DELETE FROM Usuario
			WHERE Id_usuario = @Id_usuario

			PRINT ('El usuario con id ' + CAST(@Id_usuario AS NVARCHAR(100)) + ' fue eliminado')
		END
		ELSE
			PRINT ('El usuario con id ' + CAST(@Id_usuario AS NVARCHAR(100)) + ' no existe')
	END
	ELSE IF (@Accion = 'M')
	BEGIN
		IF (EXISTS (SELECT 1 FROM Usuario WHERE Id_usuario = @Id_usuario))
		BEGIN

			IF (@Nombre IS NOT NULL AND
				dbo.f_funcion2(@Contrasenia) = 1 AND
				@Categoria IN (1, 2, NULL))
				UPDATE Usuario
				SET
					Nombre = @Nombre,
					Contrasenia = @Contrasenia,
					Id_categoria = @Categoria
				WHERE Id_usuario = @Id_usuario

			PRINT ('El usuario con id ' + CAST(@Id_usuario AS NVARCHAR(100)) + ' fue modificado')
		END
		ELSE
			PRINT ('El usuario con id ' + CAST(@Id_usuario AS NVARCHAR(100)) + ' no existe')
	END
END

--EXEC p_proceso1 'A', 101, 'Nicolas', 'P@55word', NULL
--EXEC p_proceso1 'M', 101, 'Ezequiel', 'P4ssw@rd', 1
--EXEC p_proceso1 'B', 101

--SELECT * FROM Usuario WHERE Id_usuario = 101