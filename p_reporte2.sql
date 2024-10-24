-- Este procedimiento muestra las propiedades que tienen por lo menos todos
-- los servicios que se le pasan en una tabla de tipo LISTA_SERVICIO (Id_servicio)



CREATE OR ALTER PROCEDURE p_reporte4 (@lista_servicio LISTA_SERVICIO READONLY)
AS
BEGIN
	-- si la tabla que pase por parametro no esta vacia
	IF (EXISTS (SELECT 1 FROM @lista_servicio))
	BEGIN
		
		DECLARE @servicioActual INT;

		-- tabla temporal para copiar la readonly
		CREATE TABLE #Lista_servicio (Id_servicio INT);

		INSERT INTO #Lista_servicio (Id_servicio)
		SELECT Id_servicio
		FROM @lista_servicio;
		
		-- aca va la primera iteracion,
		-- despues pierde las propiedades que no tienen los subsiguientes servicios
		CREATE TABLE #Prop_todos_servicios (Id_propiedad INT);

		-- aca van las siguientes
		CREATE TABLE #Prop_servicio (Id_propiedad INT);

		-- saco de la lista el primer servicio que pase por parametro
		SET @servicioActual = (
			SELECT TOP 1 Id_servicio
			FROM #Lista_servicio
		);

		-- y lo borro de la tabla
		DELETE FROM #Lista_servicio
		WHERE Id_servicio = @servicioActual;

		-- meto en primer_servicio las propiedades con el primer servicio en la lista
		INSERT INTO #Prop_todos_servicios
		SELECT Id_propiedad
		FROM Tiene_servicio
		WHERE Id_servicio = @servicioActual

		-- saco de la lista el siguiente servicio que pase por parametro
		SET @servicioActual = (
			SELECT TOP 1 Id_servicio
			FROM #Lista_servicio
		);

		-- en prop_servicio meto las propiedades con los subsiguientes servicios
		INSERT INTO #Prop_servicio
		SELECT Id_propiedad
		FROM Tiene_servicio
		WHERE Id_servicio = @servicioActual

		-- mientras la tabla no este vacia
		WHILE (EXISTS (SELECT 1 FROM #Lista_servicio))
		BEGIN

			-- borro de la tabla el servicio que copie antes
			-- para no cortar el while antes de tiempo
			DELETE FROM #Lista_servicio
			WHERE Id_servicio = @servicioActual;
			
			-- borro las propiedades que no se encuentren en ambas tablas
			DELETE FROM #Prop_todos_servicios
			WHERE Id_propiedad NOT IN (
				SELECT Id_propiedad
				FROM #Prop_servicio
				)

			-- vacio la tabla prop_servicio
			DELETE FROM #Prop_servicio

			-- saco de la lista el siguiente servicio que pase por parametro
			SET @servicioActual = (
				SELECT TOP 1 Id_servicio
				FROM #Lista_servicio
			);

			-- en prop_servicio meto las propiedades con el siguiente servicio
			INSERT INTO #Prop_servicio
			SELECT Id_propiedad
			FROM Tiene_servicio
			WHERE Id_servicio = @servicioActual
		END

		-- cuando termina el while la tabla prop_todos_servicios tiene
		-- solo las propiedades que tienen por lo menos TODOS los servicios que pase por parametro
		-- lo muestro junto con los servicios que tiene para comprobar que es verdad, pero podriamos sacar el ultimo join
		SELECT #Prop_todos_servicios.Id_propiedad, Propiedad.Nombre--, Tiene_servicio.Id_servicio
		FROM #Prop_todos_servicios
		INNER JOIN Propiedad
		ON Propiedad.Id_propiedad = #Prop_todos_servicios.Id_propiedad
		--INNER JOIN Tiene_servicio
		--ON #Prop_todos_servicios.Id_propiedad = Tiene_servicio.Id_propiedad

	END;

END;
GO

--ejecutar 1 vez
CREATE TYPE LISTA_SERVICIO AS TABLE (Id_servicio INT)

-- aca lo ejecuto para probarlo
-- hay que declarar una variable tabla creada por usuario que supongo que meteremos en alguno de los scripts
DECLARE @tabla LISTA_SERVICIO;

-- inserta los servicios que queres buscar
INSERT INTO @tabla (Id_servicio) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9)

-- lo ejecuta con la tabla que llenaste
EXEC p_reporte4 @lista_servicio = @tabla;