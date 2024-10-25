/*
12. tg_auditar(): Elegir alguna de las tablas que contenga datos sensibles dentro de cada
modelo. Sobre dicha tabla realizar un trigger de auditoría que permita controlar cada una de
las acciones realizadas, permitiendo conocer la acción, el momento de la acción , el usuario
que lo realizó, el valor cambiado y todo lo que considere relevante
*/
GO
CREATE TRIGGER tg_auditar
ON Propiedad
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	
	-- crea la tabla de auditoria si no existe
	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Auditoria' and xtype='U')
	BEGIN
		-- esta tabla guarda algunos datos de las propiedades que se toquen
		CREATE TABLE Auditoria (
			Id_auditoria INT NOT NULL IDENTITY,
			Nombre_usuario NVARCHAR(100) NOT NULL,
			Evento NVARCHAR(20) NOT NULL,
			Fecha_evento DATETIME NOT NULL,
			Id_propiedad INT,
			Nombre_propiedad NVARCHAR(1000),
			Noches_minimas INT,
			Precio_por_noche FLOAT,
			Latitud FLOAT,
			Longitud FLOAT,
			Id_usuario INT,
			Tipo_de_propiedad NVARCHAR(100),
			Localidad NVARCHAR(100),
			CONSTRAINT PKAuditoria
				PRIMARY KEY (Id_auditoria)
		);
	END

	-- si la tabla deleted y la tabla inserted tienen algo adentro (o sea en un update)
	IF (EXISTS (SELECT 1 FROM deleted) AND EXISTS (SELECT 1 FROM inserted))
	BEGIN
		-- mete en auditoria los registros mas la informacion de fecha y el tipo de evento modificacion
		-- los case when lo que hacen es que si no hubo update en la columna entonces pongo un null indicando que no hubo cambio
		INSERT INTO Auditoria (
			Nombre_usuario,
			Evento,
			Fecha_evento,
			Id_propiedad,
			Nombre_propiedad,
			Noches_minimas,
			Precio_por_noche,
			Latitud,
			Longitud,
			Id_usuario,
			Tipo_de_propiedad,
			Localidad
		)
		SELECT
			USER_NAME(),
			'Modificacion',
			GETDATE(),
			CASE
				WHEN UPDATE(Id_propiedad)
				THEN p.Id_propiedad
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Nombre)
				THEN p.Nombre
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Noches_minimas)
				THEN p.Noches_minimas
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Precio_por_noche)
				THEN p.Precio_por_noche
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Latitud)
				THEN p.Latitud
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Longitud)
				THEN p.Longitud
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Id_usuario)
				THEN p.Id_usuario
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(Id_tipo_de_propiedad)
				THEN t.Descripcion
				ELSE NULL
			END,
			CASE
				WHEN UPDATE(CP)
				THEN l.Nombre
				ELSE NULL
			END
		FROM inserted AS p
		INNER JOIN Tipo_de_propiedad AS t
		ON p.Id_tipo_de_propiedad = t.Id_tipo_de_propiedad
		INNER JOIN Localidad AS l
		ON p.CP = l.CP;
	END
	ELSE IF (EXISTS (SELECT 1 FROM inserted))
	BEGIN

		INSERT INTO Auditoria (
			Nombre_usuario,
			Evento,
			Fecha_evento,
			Id_propiedad,
			Nombre_propiedad,
			Noches_minimas,
			Precio_por_noche,
			Latitud,
			Longitud,
			Id_usuario,
			Tipo_de_propiedad,
			Localidad
		)
		SELECT
			USER_NAME(),
			'Insercion',
			GETDATE(),
			p.Id_propiedad,
			p.Nombre,
			p.Noches_minimas,
			p.Precio_por_noche,
			p.Latitud,
			p.Longitud,
			p.Id_usuario,
			t.Descripcion,
			l.Nombre
		FROM inserted AS p
		INNER JOIN Tipo_de_propiedad AS t
		ON p.Id_tipo_de_propiedad = t.Id_tipo_de_propiedad
		INNER JOIN Localidad AS l
		ON p.CP = l.CP;

	END
	ELSE IF (EXISTS (SELECT 1 FROM deleted))
	BEGIN

		INSERT INTO Auditoria (
			Nombre_usuario,
			Evento,
			Fecha_evento,
			Id_propiedad,
			Nombre_propiedad,
			Noches_minimas,
			Precio_por_noche,
			Latitud,
			Longitud,
			Id_usuario,
			Tipo_de_propiedad,
			Localidad
		)
		SELECT
			USER_NAME(),
			'Eliminacion',
			GETDATE(),
			p.Id_propiedad,
			p.Nombre,
			p.Noches_minimas,
			p.Precio_por_noche,
			p.Latitud,
			p.Longitud,
			p.Id_usuario,
			t.Descripcion,
			l.Nombre
		FROM deleted AS p
		INNER JOIN Tipo_de_propiedad AS t
		ON p.Id_tipo_de_propiedad = t.Id_tipo_de_propiedad
		INNER JOIN Localidad AS l
		ON p.CP = l.CP;

	END

END;

---------------------------------------------------------------------------------------------------------------------
/*
13. f_funcion1(valor): Realizar una función que permita darle formato frecuente a un campo
determinado. Se deberá elegir la función, según lo que resulte útil para el modelo diseñado.
*/
GO
--Funcion para formatear nombres 
--Ej Nombres de ususario, cambiar ej de ABEl LopEs __> Abel Lopez 


CREATE OR ALTER FUNCTION dbo.f_funcion1 (@Nombre NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Resultado NVARCHAR(100);
    
    -- Convierte el nombre a minúsculas
    SET @Resultado = LOWER(@Nombre);
    
    -- Capitaliza solo la primera letra de cada palabra
    SET @Resultado = (SELECT STRING_AGG(
                            CASE 
                                -- Si la palabra empieza con una letra  a-z, pone en MAYUSCULA la primera letra, y el resto en minuscula
                                WHEN value LIKE '[a-z]%' 
                                THEN UPPER(LEFT(value, 1)) + SUBSTRING(value, 2, LEN(value))
                                -- Si no empieza con una letra, no cambia la palabra
                                ELSE value 
                            END, 
                            ' ')
                      FROM STRING_SPLIT(@Resultado, ' '));

    RETURN @Resultado;
END;

/*
SELECT  dbo.f_funcion1('USuaRio JuanTo') as NOMBREFORMATEADO
SELECT  dbo.f_funcion1('UsUaRio jauN123 ') as NOMBREFORMATEADO
*/

/*
UPDATE Usuario
SET Nombre = dbo.f_funcion1(Nombre);
*/

/*
Select Nombre
From Usuario
*/

---------------------------------------------------------------------------------------------------------------------
/*
14. f_funcion2(contraseña): Realizar una función que permita controlar los caracteres permitidos
y reglas para el seteo de contraseñas en la aplicación. Devolverá 1 si es válida ó 0 si no
cumple las condiciones. Contemplar al menos 5 condiciones de diferente característica, por
ejemplo, la longitud.
*/
GO
CREATE OR ALTER FUNCTION f_funcion2 (@contrasenia NVARCHAR(20))
RETURNS BIT
AS
BEGIN
	IF (@contrasenia is null)
		RETURN 0;
	-- minimo 8 caracteres
	IF (LEN(@contrasenia) < 8)
		RETURN 0;

	-- minimo una mayuscula
	IF (NOT @contrasenia LIKE '%[A-Z]%')
		RETURN 0;

	-- minimo una minuscula
	IF (NOT @contrasenia LIKE '%[a-z]%')
		RETURN 0;

	-- minimo un numero
	IF (NOT @contrasenia LIKE '%[0-9]%')
		RETURN 0;

	-- minimo un caracter especial
	IF (NOT @contrasenia LIKE '%[^a-zA-Z0-9]%')
		RETURN 0;

	RETURN 1;

END;

/*
If ( dbo.f_funcion2 ('Afl123%4123') = 1)
	Print 'aceptado'
ELSE
	Print 'RECHAZADO'
*/
---------------------------------------------------------------------------------------------------------------------
/*
15. v_vista1() … v_vista3: Diseñar 3 vistas que permitan listar 3 requerimientos funcionales que
puedan presentarse en cada modelo de negocio. Las mismas deben:
■ tener complejidad media/alta, con el uso de joins, agrupaciones,
subconsultas, etc.
■ Al menos una de ellas debe mostrar un ranking de los 10
“mejores”/“peores”/”mayores”/”menores”/etc, según el requerimiento elegido
■ Al menos una de ellas debe tener recursividad con jerarquías
■ Al menos una de ellas debe contener un análisis anual de algún
requerimiento oportuno al modelo
*/
GO
CREATE VIEW v_vista1  --RANKING 
AS
WITH Fechas_por_reserva AS (
	SELECT Id_reserva, COUNT(Fecha) AS Cantidad_Fechas
	FROM Fecha_reservada
	GROUP BY Id_reserva
)

SELECT TOP 10 Usuario.Id_usuario, Fechas_por_reserva.Cantidad_fechas
FROM Reserva
INNER JOIN Fechas_por_reserva
ON Reserva.Id_reserva = Fechas_por_reserva.Id_reserva
INNER JOIN Usuario
ON Reserva.Id_usuario = Usuario.Id_usuario;

/*
SELECT p.Id_propiedad, l.Nombre
FROM Propiedad AS p
INNER JOIN Localidad AS l
ON p.CP = l.CP 
*/

GO
CREATE OR ALTER VIEW v_vista2 AS
WITH ReferentesCTE AS (
    -- Caso base: Iniciamos con cada usuario que tiene un referente directo
    SELECT Id_usuario, Id_usuario_referente, 1 AS Nivel
    FROM Usuario
    WHERE Id_usuario_referente IS NOT NULL

    UNION ALL

    -- Parte recursiva: Para cada usuario, buscamos el siguiente referente y aumentamos el nivel
    SELECT rc.Id_usuario, u.Id_usuario_referente, rc.Nivel + 1
    FROM ReferentesCTE rc
    INNER JOIN Usuario u ON rc.Id_usuario_referente = u.Id_usuario
    WHERE u.Id_usuario_referente IS NOT NULL
)

-- Contamos el numero de ancestros para cada usuario
/*
SELECT Id_usuario, MAX(Nivel) AS CantidadAncestros
FROM ReferentesCTE
GROUP BY Id_usuario;
*/

GO
CREATE OR ALTER VIEW Cantidad_Resenias_UltimoAnio AS
SELECT 
    p.Id_usuario AS IdUsuario,
    YEAR(r.Fecha_creada) AS Anio,
    COUNT(r.Id_resenia) AS CantidadResenias
FROM 
    Resenia r
JOIN 
    Propiedad p ON r.Id_propiedad = p.Id_propiedad
WHERE 
    r.Fecha_creada >= DATEADD(YEAR, -1, GETDATE())
GROUP BY 
    p.Id_usuario,
    YEAR(r.Fecha_creada);

/*
SELECT 
    CR.IdUsuario, CR.CantidadResenias 
FROM 
    Cantidad_Resenias_UltimoAnio CR
WHERE 
    Anio = 2024;
*/
---------------------------------------------------------------------------------------------------------------------
/*
16. p_reporte1() ... p_reporte5(): Diseñar 5 procedimientos almacenados que permitan listar 5
requerimientos funcionales que puedan presentarse en cada modelo de negocio. Los mismos
deben contemplar las siguientes estructuras técnicas:
a. Al menos 2 de ellos deben recibir parámetros de entrada
b. Al menos 2 de ellos deben retornar datos de salida
c. Se deben validar que los parámetros de entrada contengan valores esperados
d. Se deben contemplar el uso de todos los operadores vistos en clase:
■ Joins
■ Agrupaciones y funciones de agrupación
■ Union / Union all
■ All / any / some
■ Subconsultas
■ exists / in
■ with
*/
GO
--Genera un reporte de que caracteristicas tiene cada propiedad

CREATE OR ALTER PROCEDURE p_reporte1
AS
BEGIN
	WITH
	Propiedad_espacio AS (
		SELECT C.Id_propiedad, SUM(TC.Espacio) AS Espacio
		FROM Cama C
		INNER JOIN Tipo_de_cama TC
		ON C.Id_tipo_de_cama = TC.Id_tipo_de_cama
		GROUP BY C.Id_propiedad
	),
	Propiedad_dormitorio_banio AS (
		SELECT D.Id_propiedad, COUNT(D.Numero) AS Dormitorios, Propiedad_banio.Banios
		FROM Dormitorio D
		INNER JOIN (
			SELECT B.Id_propiedad, COUNT(B.Numero) AS Banios
			FROM Banio B
			GROUP BY B.Id_propiedad
		) AS Propiedad_banio
		ON D.Id_propiedad = Propiedad_banio.Id_propiedad
		GROUP BY D.Id_propiedad, Propiedad_banio.Banios
	),
	Propiedad_cama AS (
		SELECT Id_propiedad, COUNT(Numero_cama) AS Camas
		FROM Cama C
		GROUP BY Id_propiedad
	)

	SELECT P.Nombre, PDB.Banios, PDB.Dormitorios, PC.Camas, PE.Espacio, P.Id_propiedad
	FROM Propiedad P
	INNER JOIN Propiedad_espacio PE
	ON P.Id_propiedad = PE.Id_propiedad
	INNER JOIN Propiedad_dormitorio_banio PDB
	ON PDB.Id_propiedad = P.Id_propiedad
	INNER JOIN Propiedad_cama PC
	ON PC.Id_propiedad = P.Id_propiedad
END
/*
exec p_reporte1
*/
-------------------------------------------------------------------------------
--REPORTE 2

-- Este procedimiento muestra las propiedades que tienen por lo menos todos
-- los servicios que se le pasan en una tabla de tipo LISTA_SERVICIO (Id_servicio)

IF NOT EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'LISTA_SERVICIO')
BEGIN
    CREATE TYPE LISTA_SERVICIO AS TABLE (Id_servicio INT);
END;

CREATE OR ALTER PROCEDURE p_reporte2 (@lista_servicio LISTA_SERVICIO READONLY)
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
		IF (@servicioActual < 0) 
		BEGIN 
			PRINT 'Id de Servicio no puede ser negativo'
			Return
		END

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


-- aca lo ejecuto para probarlo
-- hay que declarar una variable tabla creada por usuario que supongo que meteremos en alguno de los scripts
-- inserta los servicios que queres buscar
-- lo ejecuta con la tabla que llenaste
/*
DECLARE @tabla LISTA_SERVICIO;

INSERT INTO @tabla (Id_servicio) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9)

EXEC p_reporte2 @lista_servicio = @tabla;
*/

GO
--Reporte 3 --BUSCA HABITACIONES DIPONIBLES, le paso las fechas que necesito, y la cantidad de lugares
--fecha inicio, fecha fin y lugares necesarios


CREATE OR ALTER PROCEDURE p_reporte3
    @FechaInicio DATE,
    @FechaFin DATE,
    @lugares INT
AS
BEGIN
	IF (@lugares < 0) 
	BEGIN 
		PRINT 'Id de Propiedad no puede ser negativo'
		Return
	END
  -- Tabla temporal para almacenar resultados de p_reporte1
    CREATE TABLE #Reporte  (Id_propiedad INT,Nombre NVARCHAR(255),Banios INT,Dormitorios INT,Camas INT,Espacio INT);

    -- Insertar los resultados de p_reporte1 en la tabla temporal
    INSERT INTO #Reporte (Nombre, Banios, Dormitorios, Camas, Espacio, Id_propiedad)
    EXEC p_reporte1;

    -- Ahora filtra las propiedades en función de las reservas y el espacio necesario
    SELECT R.Nombre, R.Espacio, R.Id_propiedad
    FROM #Reporte R
    WHERE R.Espacio >= @lugares
    AND R.Id_propiedad NOT IN (
        SELECT R.Id_propiedad
        FROM Reserva R
        INNER JOIN Fecha_reservada FR ON R.Id_reserva = FR.Id_reserva
        WHERE FR.fecha BETWEEN @FechaInicio AND @FechaFin
    );

    -- Eliminar la tabla temporal
    DROP TABLE #Reporte;
END;

/*
exec p_reporte3 '2024-10-01', '2024-10-05', 5;
*/

GO
--REPORTE 4
--BUSCA LAS PROPIEDADES DISPONIBLES DENTRO DE UN RADIO

CREATE OR ALTER PROCEDURE p_reporte4
    @IdPropiedad INT,  -- ID de la propiedad que servirá como punto central
    @Radio INT       -- Radio en metros
AS
BEGIN
	IF (@Radio < 0) 
	BEGIN 
		PRINT 'Radio no puede ser negativo'
		Return
	END
	IF (@IdPropiedad < 0) 
	BEGIN 
		PRINT 'Id de propiedad no puede ser negativo'
		Return
	END
    -- Declarar variables para almacenar la latitud y longitud de la propiedad
    DECLARE @LatitudCentro FLOAT;
    DECLARE @LongitudCentro FLOAT;
	
	IF((Select Id_propiedad
	FROM Propiedad
    WHERE Id_propiedad = @IdPropiedad) is null)
	    BEGIN
        PRINT 'Propiedad no encontrada.';
        RETURN;
	END

    -- Obtener la latitud y longitud de la propiedad con el Id proporcionado
    SELECT @LatitudCentro = Latitud, @LongitudCentro = Longitud
    FROM Propiedad
    WHERE Id_propiedad = @IdPropiedad;

    -- Si la propiedad no existe, retornar un mensaje de error
	IF @LatitudCentro IS NULL OR @LongitudCentro IS NULL
	BEGIN
		PRINT 'Longitud o Latitud no encontradas';
		RETURN;
	END

    -- Buscar propiedades dentro del radio especificado usando la fórmula Haversine
    SELECT Id_propiedad, Nombre,
        (6371000 * ACOS(COS(RADIANS(@LatitudCentro)) 
        * COS(RADIANS(Latitud)) 
        * COS(RADIANS(Longitud) - RADIANS(@LongitudCentro)) 
        + SIN(RADIANS(@LatitudCentro)) 
        * SIN(RADIANS(Latitud)))) AS Distancia_en_Metros --formula para encontrar la distancia
    FROM Propiedad
    WHERE Id_propiedad <> @IdPropiedad  -- menos la propiedad que le mande
      AND (6371000 * ACOS(COS(RADIANS(@LatitudCentro)) 
        * COS(RADIANS(Latitud)) 
        * COS(RADIANS(Longitud) - RADIANS(@LongitudCentro)) 
        + SIN(RADIANS(@LatitudCentro)) 
        * SIN(RADIANS(Latitud)))) <= @Radio
    ORDER BY Distancia_en_Metros ASC;
END;
/*
DECLARE @propiedad INT;
SET @propiedad = (Select TOP 1 p.Id_propiedad from Propiedad p where p.Id_propiedad>5000 );

EXEC p_reporte4
    @IdPropiedad = -@propiedad,  -- ID de la propiedad desde la cual calcular el radio
    @Radio = 100;         -- Radio en metros
*/
--REPORTE 5
GO
CREATE OR ALTER PROCEDURE p_reporte5
	@anio INT,
	@propiedad_anio INT OUTPUT,
	@propiedad_anio_anterior INT OUTPUT
AS 
BEGIN
	DECLARE @resultado TABLE (Id_propiedad INT, cant_dias INT, Anio INT)

	INSERT INTO @resultado
	SELECT c1.Id_propiedad, c1.cant_dias, (@anio - 1) AS Anio
	FROM (
		SELECT r.Id_propiedad, COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = (@anio - 1)
		GROUP BY r.Id_propiedad
	) c1
	WHERE c1.cant_dias >= ALL (
		SELECT COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = (@anio - 1)
		GROUP BY r.Id_propiedad
	)
	UNION
	SELECT c2.Id_propiedad, c2.cant_dias, @anio AS Anio
	FROM (
		SELECT r.Id_propiedad, COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = @anio
		GROUP BY r.Id_propiedad
	) c2
	WHERE c2.cant_dias >= ALL (
		SELECT COUNT(f.Fecha) AS cant_dias
		FROM Reserva r
		INNER JOIN Fecha_reservada f
		ON r.Id_reserva = f.Id_reserva
		WHERE YEAR(f.Fecha) = @anio
		GROUP BY r.Id_propiedad
	)

	SET @propiedad_anio = (
		SELECT Id_propiedad
		FROM @resultado
		WHERE Anio = @anio
	)
	SET @propiedad_anio_anterior = (
		SELECT Id_propiedad
		FROM @resultado
		WHERE Anio = (@anio - 1)
	)
END
/*
DECLARE @actual INT
DECLARE @anterior INT

EXEC p_reporte5 @anio = 2024, @propiedad_anio = @actual OUTPUT, @propiedad_anio_anterior = @anterior OUTPUT

PRINT ('anio pedido: ' + CAST(@actual AS CHAR))
PRINT ('anio anterior: ' + CAST(@anterior AS CHAR))
*/


---------------------------------------------------------------------------------------------------------------------
/*
17. p_proceso1(datos_del_usuario): Diseñar un procedimiento almacenado que permita
realiza el alta/baja/modificación de un nuevo usuario en nuestro sistema, contemplando
diferentes características, tales como que el usuario no exista/exista, que cumpla con las
condiciones de contraseñas, que haya completado todos los datos mínimos necesarios, las
relaciones que se afectarían, etc.
*/

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