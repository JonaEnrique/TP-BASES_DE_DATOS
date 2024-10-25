/*
8. p_CrearDB(borrar_si_existe?): Desarrollar un procedimiento almacenado que permita crear
la base de datos con sus tablas, claves primarias, claves foráneas y todo lo relacionado al
esquema de la base de datos. Según el parámetro enviado, se debe o no borrar la estructura
si existía previamente.*/--CREATE DATABASE Airbnb;GOCREATE OR ALTER PROCEDURE p_CrearDB (@borrar_si_existe bit)
AS
BEGIN

	IF (@borrar_si_existe = 1)
	BEGIN
		DROP TABLE IF EXISTS Cama;
		DROP TABLE IF EXISTS Tipo_de_cama;
		DROP TABLE IF EXISTS Dormitorio;
		DROP TABLE IF EXISTS Banio;
		DROP TABLE IF EXISTS Habitacion;
		DROP TABLE IF EXISTS Resenia;
		DROP TABLE IF EXISTS Fecha_reservada;
		DROP TABLE IF EXISTS Reserva;	
		DROP TABLE IF EXISTS Reserva_fecha_efectuada;
		DROP TABLE IF EXISTS Tiene_servicio;
		DROP TABLE IF EXISTS Servicio;
		DROP TABLE IF EXISTS Propiedad;
		DROP TABLE IF EXISTS Localidad;
		DROP TABLE IF EXISTS Tipo_de_propiedad;
		DROP TABLE IF EXISTS Usuario;
		DROP TABLE IF EXISTS Categoria;
	END

	-- Categor�a(Id_categor�a, Nombre)
	CREATE TABLE Categoria (
		Id_categoria INT NOT NULL,
		Nombre NVARCHAR(100) NOT NULL,
		CONSTRAINT PKCategoria
			PRIMARY KEY (Id_categoria)
	);

	-- Usuario(Id_usuario, Nombre, Id_categor�a)
	CREATE TABLE Usuario (
		Id_usuario INT NOT NULL,
		Nombre NVARCHAR(100) NOT NULL,
		Contrasenia NVARCHAR(20) NOT NULL,
		Id_categoria INT,
		Id_usuario_referente INT,
		CONSTRAINT PKUsuario
			PRIMARY KEY (Id_usuario),
		CONSTRAINT FKCategoria_de_anfitrion
		FOREIGN KEY (Id_categoria)
		REFERENCES Categoria (Id_categoria),
		CONSTRAINT FKUsario
		FOREIGN KEY (Id_usuario_referente)
		REFERENCES Usuario (Id_usuario)
	);

	-- Tipo_de_propiedad(Id_tipo_de_propiedad, Descripci�n)
	CREATE TABLE Tipo_de_propiedad (
		Id_tipo_de_propiedad INT NOT NULL IDENTITY,
		Descripcion NVARCHAR(100) NOT NULL,
		CONSTRAINT PKTipo_de_propiedad
			PRIMARY KEY (Id_tipo_de_propiedad)
	)

	-- Localidad(CP, Nombre)
	CREATE TABLE Localidad (
		CP INT NOT NULL IDENTITY,
		Nombre NVARCHAR(100) NOT NULL,
		CONSTRAINT PKLocalidad
			PRIMARY KEY (CP)
	);

	-- Propiedad(Id_propiedad, Nombre, Descripci�n, Noches_m�nimas, Precio_por_noche, Latitud, Longitud, Id_usuario, Id_tipo_de_propiedad, CP)
	CREATE TABLE Propiedad (
		Id_propiedad INT NOT NULL,
		Nombre NVARCHAR(1000) NOT NULL,
		Noches_minimas INT NOT NULL,
		Precio_por_noche FLOAT NOT NULL,
		Latitud FLOAT NOT NULL,
		Longitud FLOAT NOT NULL,
		Id_usuario INT,
		Id_tipo_de_propiedad INT,
		CP INT,
		CONSTRAINT PKPropiedad
			PRIMARY KEY (Id_propiedad),
		CONSTRAINT FKUsuario_duenio
			FOREIGN KEY (Id_usuario)
			REFERENCES Usuario (Id_usuario),
		CONSTRAINT FKTipo_de_propiedad
			FOREIGN KEY (Id_tipo_de_propiedad)
			REFERENCES Tipo_de_propiedad (Id_tipo_de_propiedad),
		CONSTRAINT FKCP_ubicacion
			FOREIGN KEY (CP)
			REFERENCES Localidad (CP)
	);

	-- Reserva(Id_reserva, Id_propiedad, Id_usuario)
	CREATE TABLE Reserva (
		Id_reserva INT NOT NULL IDENTITY,
		Id_propiedad INT NOT NULL,
		Id_usuario INT NOT NULL,
		CONSTRAINT PKReservado_por
			PRIMARY KEY (Id_reserva),
		CONSTRAINT FKPropiedad_reservada
			FOREIGN KEY (Id_propiedad)
			REFERENCES Propiedad (Id_propiedad),
		CONSTRAINT FKReservado_por_usuario
			FOREIGN KEY (Id_usuario)
			REFERENCES Usuario (Id_usuario)
	);

	-- Reserva_fecha_efectuada(Id_reserva, Fecha_efectuada)
	CREATE TABLE Reserva_fecha_efectuada (
		Id_reserva INT NOT NULL,
		Fecha_efectuada DATE NOT NULL,
		CONSTRAINT PKReserva
			PRIMARY KEY (Id_reserva)
	)

	-- Fecha_reservada(Id_propiedad, Id_usuario, fecha)
	CREATE TABLE Fecha_reservada (
		Id_reserva INT NOT NULL,
		Fecha DATE NOT NULL,
		CONSTRAINT PKFecha_reservada
			PRIMARY KEY (Id_reserva, Fecha),
		CONSTRAINT FKReservado_por
			FOREIGN KEY (Id_reserva)
			REFERENCES Reserva (Id_reserva),
	);

	-- Servicio(Id_servicio, Descripci�n)
	CREATE TABLE Servicio (
		Id_servicio INT NOT NULL IDENTITY,
		Descripcion NVARCHAR(100) NOT NULL,
		CONSTRAINT PKServicio
			PRIMARY KEY (Id_servicio)
	);

	-- Tiene_servicio(Id_propiedad, Id_servicio)
	CREATE TABLE Tiene_servicio (
		Id_propiedad INT NOT NULL,
		Id_servicio INT NOT NULL,
		CONSTRAINT PKTiene_servicio
			PRIMARY KEY (Id_propiedad, Id_servicio),
		CONSTRAINT FKPropiedad_con_servicio
			FOREIGN KEY (Id_propiedad)
			REFERENCES Propiedad (Id_propiedad),
		CONSTRAINT FKServicio_de_la_propiedad
			FOREIGN KEY (Id_servicio)
			REFERENCES Servicio (Id_servicio)
	);

	-- Rese�a(Id_rese�a, Comentario, Calificaci�n, Id_propiedad, Id_usuario)
	CREATE TABLE Resenia (
		Id_resenia INT NOT NULL IDENTITY,
		Comentario NVARCHAR(1000),
		Calificacion TINYINT NOT NULL,
		Fecha_creada DATE NOT NULL,
		Id_propiedad INT NOT NULL,
		Id_usuario INT NOT NULL,
		CONSTRAINT PKResenia
			PRIMARY KEY (Id_resenia),
		CONSTRAINT FKResenia_a_propiedad
			FOREIGN KEY (Id_propiedad)
			REFERENCES Propiedad (Id_propiedad),
		CONSTRAINT FKUsuario_autor
			FOREIGN KEY (Id_usuario)
			REFERENCES Usuario (Id_usuario)
	);

	-- Habitaci�n(Id_propiedad, N�mero, Tipo)
	CREATE TABLE Habitacion (
		Id_propiedad INT NOT NULL,
		Numero INT NOT NULL,
		Tipo NVARCHAR(100),
		CONSTRAINT PKHabitacion
			PRIMARY KEY (Id_propiedad, Numero),
		CONSTRAINT FKPropiedad_duenia
			FOREIGN KEY (Id_propiedad)
			REFERENCES Propiedad (Id_propiedad)
	);

	-- Dormitorio(Id_propiedad, N�mero)
	CREATE TABLE Dormitorio (
		Id_propiedad INT NOT NULL,
		Numero INT NOT NULL,
		CONSTRAINT PKDormitorio
			PRIMARY KEY (Id_propiedad, Numero),
		CONSTRAINT FKHabitacion_padre_dormitorio
			FOREIGN KEY (Id_propiedad, Numero)
			REFERENCES Habitacion (Id_propiedad, Numero)
	);

	-- Ba�o(Id_propiedad, N�mero)
	CREATE TABLE Banio (
		Id_propiedad INT NOT NULL,
		Numero INT NOT NULL,
		CONSTRAINT PKBanio
			PRIMARY KEY (Id_propiedad, Numero),
		CONSTRAINT FKHabitacion_padre_banio
			FOREIGN KEY (Id_propiedad, Numero)
			REFERENCES Habitacion (Id_propiedad, Numero)
	);

	-- Tipo_de_cama(Id_tipo_de_cama, Descripci�n)
	CREATE TABLE Tipo_de_cama (
		Id_tipo_de_cama INT NOT NULL IDENTITY,
		Descripcion NVARCHAR(100) NOT NULL,
		Espacio INT NOT NULL,
		CONSTRAINT PKTipo_de_cama
			PRIMARY KEY (Id_tipo_de_cama)
	);

	-- Cama(Id_propiedad, N�mero, N�mero_cama, Id_tipo_de_cama)
	CREATE TABLE Cama (
		Id_propiedad INT NOT NULL,
		Numero INT NOT NULL,
		Numero_cama INT NOT NULL,
		Id_tipo_de_cama INT NOT NULL,
		CONSTRAINT PKCama
			PRIMARY KEY (Id_propiedad, Numero, Numero_cama),
		CONSTRAINT FKDormitorio_duenio
			FOREIGN KEY (Id_propiedad, Numero)
			REFERENCES Dormitorio (Id_propiedad, Numero)
	);

END;

--exec p_CrearDB @borrar_si_existe=1;

/*
9. p_LimpiarDatos(): Desarrollar un procedimiento almacenado que permita limpiar todos los
datos almacenados en la base de datos, sin borrar estructuras.*/GOCREATE OR ALTER PROCEDURE p_LimpiarDatos
AS
BEGIN

	DELETE FROM Cama;
	DELETE FROM Tipo_de_cama;
	DELETE FROM Dormitorio;
	DELETE FROM Banio;
	DELETE FROM Habitacion;
	DELETE FROM Resenia;
	DELETE FROM Fecha_reservada;
	DELETE FROM Reserva_fecha_efectuada;
	DELETE FROM Reserva;
	DELETE FROM Tiene_servicio;
	DELETE FROM Servicio;
	DELETE FROM Propiedad;
	DELETE FROM Localidad;
	DELETE FROM Tipo_de_propiedad;
	DELETE FROM Usuario;
	DELETE FROM Categoria;

END;

/*
10. p_CagarDataset(archivo): Desarrollar un procedimiento almacenado que permita cargar el
dataset propuesto en cada caso. Se podrá contemplar la carga en una tabla temporal para
luego distribuir los datos en las distintas tablas. En el caso que el dataset tuviera datos
incorrectos, no consistentes o faltantes, se podría implementar la estrategia de completarlo,
corregirlo o suprimirlo. La carga se debe realizar desde el path del archivo enviado por
parámetro.*/
GO
CREATE PROCEDURE p_CargarDataset (@archivo NVARCHAR(100))
AS
BEGIN
	
	-- para que no de error de formato cuando agarra la fecha
	SET DATEFORMAT DMY;

	-- tabla como la de kaggle
	CREATE TABLE tabla_temporal (
		Id_propiedad INT,
		Nombre_propiedad NVARCHAR(1000),
		Id_usuario INT,
		Nombre_usuario NVARCHAR(100),
		Localidad NVARCHAR(100),
		Latitud FLOAT,
		Longitud FLOAT,
		Tipo_de_propiedad NVARCHAR(100),
		Precio_por_noche FLOAT,
		Noches_minimas INT,
		Numero_de_reviews INT,
		Ultima_review DATE,
		Reviews_mensuales FLOAT,
		Cantidad_de_publicaciones INT,
		Disponibilidad_365 INT
	);


	-- esto esta hecho de esta forma porque BULK INSERT no admite variables en el FROM, asi que hay que hacer esto raro
	DECLARE @bulk NVARCHAR(MAX);
	-- declaro una variable con el query que no hay que tocar mucho porque se rompe facil
	SET @bulk = 'BULK INSERT tabla_temporal
	FROM ''' +  @archivo + '''
	 WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		FORMAT = ''CSV'',
		FIELDQUOTE = ''"''
	);';

	-- y la ejecuto como si fuera in stored procedure
	EXEC (@bulk);

	-- Lleno localidad con los nombres y los "CP" distintos encontrados en el dataset
	INSERT INTO Localidad (Nombre)
	SELECT DISTINCT tabla_temporal.Localidad FROM tabla_temporal;

	-- Lleno los tipos con los tipos de propiedad distintos encontrados en el dataset
	INSERT INTO Tipo_de_propiedad (Descripcion)
	SELECT DISTINCT tabla_temporal.Tipo_de_propiedad
	FROM tabla_temporal;

	INSERT INTO Categoria (Id_categoria, Nombre)
	VALUES (1, 'Anfitrion');
	INSERT INTO Categoria (Id_categoria, Nombre)
	VALUES (2, 'SuperAnfitrion');

	-- Creo una tabla temporal con id, nombre y cantidad de reviews
	CREATE TABLE #Usuario_reviews (
		Id_usuario INT,
		Nombre_usuario NVARCHAR(100),
		Reviews_totales INT
	);

	-- La lleno con el total de reviews hechas a propiedades cada usuario
	INSERT INTO #Usuario_reviews
	SELECT Id_usuario, Nombre_usuario, SUM(Numero_de_reviews) AS reviews
	FROM tabla_temporal
	GROUP BY Id_usuario, Nombre_usuario;

	-- Obtengo el promedio de reviews
	DECLARE @promedio_reviews TINYINT;
	SET @promedio_reviews = (SELECT AVG(Reviews_totales) FROM #Usuario_reviews);

	-- Si el total de reviews es mayor al promedio de reviews la categoria es 2, si no 1
	INSERT INTO Usuario (Id_usuario, Nombre, Contrasenia, Id_categoria)
	SELECT 
		Id_usuario,
		Nombre_usuario,
		'P4ssW@rd',
		CASE
			WHEN Reviews_totales > @promedio_reviews THEN 2
			ELSE 1
		END
	FROM #Usuario_reviews
	WHERE Nombre_usuario IS NOT NULL;

	DROP TABLE #Usuario_reviews;

	-- anterior, sin categoria
	--INSERT INTO Usuario (Id_usuario, Nombre)
	--SELECT DISTINCT
	--	tabla_temporal.Id_usuario,
	--	tabla_temporal.Nombre_usuario
	--FROM tabla_temporal
	--WHERE tabla_temporal.Nombre_usuario IS NOT NULL;

	-- Lleno propiedad con las del dataset y los foreign keys de usuario, localidad y tipo_de_propiedad ya cargados
	INSERT INTO Propiedad (
		Id_propiedad,
		Nombre,
		Noches_minimas,
		Precio_por_noche,
		Latitud,
		Longitud,
		Id_usuario,
		Id_tipo_de_propiedad,
		CP
	)
	SELECT
		tabla_temporal.Id_propiedad,
		tabla_temporal.Nombre_propiedad,
		tabla_temporal.Noches_minimas,
		tabla_temporal.Precio_por_noche,
		tabla_temporal.Latitud,
		tabla_temporal.Longitud,
		tabla_temporal.Id_usuario,
		Tipo_de_propiedad.Id_tipo_de_propiedad,
		Localidad.CP
	FROM tabla_temporal
	INNER JOIN Localidad
	ON Localidad.Nombre = tabla_temporal.Localidad
	INNER JOIN Tipo_de_propiedad
	ON Tipo_de_propiedad.Descripcion = tabla_temporal.Tipo_de_propiedad
	WHERE tabla_temporal.Nombre_propiedad IS NOT NULL AND tabla_temporal.Nombre_usuario IS NOT NULL;

drop table tabla_temporal;
END;

--exec p_CargarDataset @archivo = '';--insertar path del excel Datos_Kaggle.csv

/*
11. p_CargaAleatoria(): Desarrollar un procedimiento almacenado que permita cargar el juego
de datos que se utilizarán para la generación de filas en cada una de las entidades
diseñadas en el modelo. Se deben controlar los errores de carga.*/
-- GENERA USUARIOS QUE NO SON DUEÑOS DE PROPIEDADES

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
GO

-- GENERA RESERVAS A PROPIEDADES Y SUS FECHAS CORRESPONDIENTES

DECLARE @cantidadFechas INT;
DECLARE @cantidadPropiedades INT = 20;

DECLARE @Id_propiedad INT;
DECLARE @Fecha_efectuada DATE;
DECLARE @Noches_minimas INT;
DECLARE @Fecha_reservada DATE
DECLARE @Id_reserva INT = 1;
DECLARE @cantidadReservas INT;


-- creo una tabla temporal
CREATE TABLE #Propiedades_random (Id_propiedad INT)
	
-- la lleno con @cantidadReservas ids de propiedad random
INSERT INTO #Propiedades_random (Id_propiedad)
SELECT TOP (@cantidadPropiedades) Id_propiedad
FROM Propiedad
ORDER BY NEWID(); --hace que ordene de forma random los ID de propiedad

-- cantidad de reservas a generar
WHILE (@cantidadPropiedades > 0)
BEGIN
	-- asigno el primero a la variable
	SET @Id_propiedad = (
		SELECT TOP 1 Id_propiedad
		FROM #Propiedades_random
		ORDER BY Id_propiedad
	);

	-- borro la que use de la tabla
	DELETE FROM #Propiedades_random
	WHERE Id_propiedad = @Id_propiedad;

	-- la fecha de hoy menos 0 a 365 dias
	SET @Fecha_efectuada = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());

	-- entre 1 y 5 reservas en la misma propiedad
	SET @cantidadReservas = 1 + FLOOR(RAND() * 4)
	
	-- mientras haya reservas por hacer
	WHILE (@cantidadReservas > 0)
	BEGIN
		-- inserta una reserva con un huesped random
		INSERT INTO Reserva (Id_propiedad, Id_usuario)
		VALUES (@Id_propiedad, 1 + FLOOR(RAND() * 99));

		INSERT INTO Reserva_fecha_efectuada (Id_reserva, Fecha_efectuada)
		VALUES (@Id_reserva, @Fecha_efectuada)

		-- saca las noches minimas de la propiedad reservada
		SET @Noches_minimas = (
			SELECT Noches_minimas
			FROM Propiedad
			WHERE Id_propiedad = @Id_propiedad
		);

		-- establece la reservada mas 1 a 31 dias como primera fecha
		SET @Fecha_reservada = DATEADD(DAY, 1 + FLOOR(RAND() * 30), @Fecha_efectuada);

		-- hace tantas fechas como noches minimas acepta la propiedad
		WHILE (@Noches_minimas > 0)
		BEGIN

			-- inserta la fecha 
			INSERT INTO Fecha_reservada (Id_reserva, Fecha)
			VALUES (@Id_reserva, @Fecha_reservada);

			-- le suma uno a la fecha
			SET @Fecha_reservada = DATEADD(DAY, 1, @Fecha_reservada);

			-- disminuye las noches para el while
			SET @Noches_minimas -= 1;

		END;

		-- setea la fecha efectuada a la ultima fecha reservada para que no se pisen las reservas
		SET @Fecha_efectuada = @Fecha_reservada
		SET @CantidadReservas -= 1;
		
		-- aumenta para que no se defase con el identity de reserva
		SET @Id_reserva += 1;

	END;

	SET @cantidadPropiedades -= 1;

END;
-- dropeo la tabla temporal
DROP TABLE #Propiedades_random;
GO

-- GENERA RESENIAS A PROPIEDADES POR USUARIOS

CREATE TABLE #Propiedades_random (Id_propiedad INT);
CREATE TABLE #Usuarios_random (Id_usuario INT);

DECLARE @cantidadResenias INT = 20;
DECLARE @comentario NVARCHAR(1000);
DECLARE @calificacion TINYINT;
DECLARE @fechaCreada DATE;
DECLARE @idPropiedad INT;
DECLARE @idUsuario INT;

INSERT INTO #Propiedades_random (Id_propiedad)
SELECT TOP (@cantidadResenias) Id_propiedad
FROM Propiedad
ORDER BY NEWID();

INSERT INTO #Usuarios_random (Id_usuario)
SELECT TOP (@cantidadResenias) Id_usuario
FROM Usuario
ORDER BY NEWID();


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

GO

-- GENERA SERVICIOS Y ASIGNA SERVICIOS A PROPIEDADES

DECLARE @cantidad INT = 1;
DECLARE @descripcionServicio NVARCHAR(100) = 'Servicio ';

IF OBJECT_ID('tempdb..#Propiedades_random') IS NOT NULL
    DROP TABLE #Propiedades_random;
IF OBJECT_ID('tempdb..#Servicios_random') IS NOT NULL
    DROP TABLE #Servicios_random;

IF EXISTS (SELECT 1 FROM Tiene_servicio)
    DELETE FROM Tiene_servicio;

IF EXISTS (SELECT 1 FROM Servicio)
    DELETE FROM Servicio;



WHILE (@cantidad < 41)
BEGIN
	
	INSERT INTO Servicio(Descripcion)
	VALUES (
		@descripcionServicio + CAST(@cantidad AS CHAR)
	)

	SET @cantidad += 1;

END

--Tiene Servicios

DECLARE @Id_propiedad INT;
DECLARE @Id_servicio INT;
DECLARE @cantidadServicios INT = 30;
DECLARE @cantidadPropiedades INT = 50;

DECLARE @serviciosPorPropiedad INT; 

-- creo una tabla temporal PROPIEDAD
CREATE TABLE #Propiedades_random (Id_propiedad INT)
	
-- la lleno con @cantidadPropiedades ids de propiedad random
INSERT INTO #Propiedades_random (Id_propiedad)
SELECT TOP (@cantidadPropiedades) Id_propiedad
FROM Propiedad
ORDER BY NEWID(); --hace que ordene de forma random los ID de propiedad

-- creo una tabla temporal SERVICIO
CREATE TABLE #Servicios_random (Id_servicio INT)
	


--cantidad de propiedades que tienen servicio
WHILE (@cantidadPropiedades>0)
BEGIN
	SET @Id_propiedad = (
		SELECT TOP 1 Id_propiedad
		FROM #Propiedades_random
		ORDER BY Id_propiedad
	);

		-- borro la que use de la tabla
	DELETE FROM #Propiedades_random
	WHERE Id_propiedad = @Id_propiedad;

	-- la lleno con @cantidadServicios ids de servicios random
	INSERT INTO #Servicios_random (Id_servicio)
	SELECT TOP (@cantidadServicios) Id_servicio
	FROM Servicio
	ORDER BY NEWID(); --hace que ordene de forma random los ID de servicio
	
	SET @serviciosPorPropiedad = 1 + FLOOR(RAND() * 10); --puedo tener de 1 a 10 servicios
	WHILE (@serviciosPorPropiedad>0)
	BEGIN

		SET @Id_servicio = ( --cargo un servicio
		SELECT TOP 1 Id_servicio
		FROM #Servicios_random
		ORDER BY Id_servicio
		);

		-- borro la que use de la tabla
		DELETE FROM #Servicios_random
		WHERE Id_servicio = @Id_servicio;

		INSERT INTO Tiene_servicio(Id_propiedad,Id_servicio)
		VALUES (@Id_propiedad, @Id_servicio);

		SET @serviciosPorPropiedad -= 1;
	END		
	SET @cantidadPropiedades -= 1;
END

DROP TABLE #Propiedades_random

DROP TABLE #Servicios_random
GO

-- GENERA HABITACIONES (DORMITORIOS Y BANIOS) CON SUS RESPECTIVAS CAMAS

DECLARE @cantidadPropiedades INT = 1000;

DECLARE @propiedadActual INT;
DECLARE @tipoDePropiedadActual INT;
DECLARE @cantidadHabitaciones INT;
DECLARE @cantidadDormitorios INT;
DECLARE @cantidadBanios INT;
DECLARE @numeroHabitacion INT;
DECLARE @cantidadCamas INT;
DECLARE @numeroCama INT;
DECLARE @tipoDeCama INT;

-- tipos de cama
-- 1 una plaza
-- 2 dos plazas
-- 3 litera

-- tipos de propiedad
-- 1 habitacion de hotel
-- 2 habitacion compartida
-- 3 habitacion privada
-- 4 casa entera/departamento

-- los tipos de cama los creo manualmente
INSERT INTO Tipo_de_cama (Descripcion, Espacio)
VALUES
('Una plaza', 1),
('Dos plazas', 2),
('Litera', 2)

-- agarro @cantidadDePropiedades propiedades random y las meto en una tabla temporal
-- porque si lo hago con las 22000 propiedades tarda como 2 minutos en ejecutar
CREATE TABLE #PropiedadesRandom (Id_propiedad INT, Id_tipo_de_propiedad INT);

INSERT INTO #PropiedadesRandom
SELECT TOP (@cantidadPropiedades) Id_propiedad, Id_tipo_de_propiedad
FROM Propiedad
ORDER BY NEWID();

-- mientras la tabla contenga algo
WHILE (EXISTS (SELECT 1 FROM #PropiedadesRandom))
BEGIN

	-- elijo el primer id de la tabla temporal
	SET @propiedadActual = (
		SELECT TOP 1 Id_propiedad
		FROM #PropiedadesRandom
		ORDER BY Id_propiedad
	);

	-- y su tipo de propiedad
	SET @tipoDePropiedadActual = (
		SELECT Id_tipo_de_propiedad
		FROM #PropiedadesRandom
		WHERE Id_propiedad = @propiedadActual
	);

	-- y la elimino de la tabla
	DELETE FROM #PropiedadesRandom
	WHERE Id_propiedad = @propiedadActual;

	-- si el tipo es de hotel o compartida
	IF (@tipoDePropiedadActual = 1 OR @tipoDePropiedadActual = 2)
	BEGIN
		-- tiene 2 habitaciones, un dormitorio y un ba�o siempre
		SET @cantidadHabitaciones = 2;
		SET @cantidadDormitorios = 1;
		SET @cantidadBanios = 1;
	END
	-- si es privada 
	ELSE IF (@tipoDePropiedadActual = 3)
	BEGIN
		-- tiene solamente ba�o
		SET @cantidadDormitorios = 0;
		SET @cantidadBanios = 1;
	END
	-- si es una casa o departamento
	ELSE IF (@tipoDePropiedadActual = 4)
	BEGIN
		-- tiene entre 2 y 7 habitaciones, por lo menos un dormitorio y el resto banios
		SET @cantidadHabitaciones = 2 + FLOOR(RAND() * 5);
		SET @cantidadDormitorios = 1 + FLOOR(RAND() * (@cantidadHabitaciones - 2));
		SET @cantidadBanios = @cantidadHabitaciones - @cantidadDormitorios;
	END

	-- empiezo por la habitacion 1
	SET @numeroHabitacion = 1;

	-- y mientras queden dormitorios sin asignar
	WHILE (@numeroHabitacion <= @cantidadDormitorios)
	BEGIN

		-- inserto un dormitorio en las tablas
		INSERT INTO Habitacion (Id_propiedad, Numero, Tipo)
		VALUES (@propiedadActual, @numeroHabitacion, 'Dormitorio');

		INSERT INTO Dormitorio (Id_propiedad, Numero)
		VALUES (@propiedadActual, @numeroHabitacion);

		-- elijo un numero random de camas entre 1 y 2
		SET @cantidadCamas = 1 + FLOOR(RAND())

		-- empiezo por la cama 1
		SET @numeroCama = 1 ;

		-- mientras queden camas sin asignar
		WHILE (@numeroCama <= @cantidadCamas)
		BEGIN
			
			-- elijo un tipo de cama random entre 1 y 3
			SET @tipoDeCama = 1 + FLOOR(RAND() * 2);

			-- inserto una cama nueva de un tipo random
			INSERT INTO Cama (Id_propiedad, Numero, Numero_cama, Id_tipo_de_cama)
			VALUES (@propiedadActual, @numeroHabitacion, @numeroCama, @tipoDeCama);

			SET @numeroCama += 1;

		END;

		SET @numeroHabitacion += 1;

	END;

	-- mientras queden habitaciones sin asignar
	WHILE (@numeroHabitacion <= @cantidadDormitorios + @cantidadBanios)
	BEGIN

		-- inserto un banio en las tablas
		INSERT INTO Habitacion (Id_propiedad, Numero, Tipo)
		VALUES (@propiedadActual, @numeroHabitacion, 'Banio');

		INSERT INTO Banio (Id_propiedad, Numero)
		VALUES (@propiedadActual, @numeroHabitacion);

		SET @numeroHabitacion += 1;

	END;

END;

-- dropeo la tabla temporal
DROP TABLE #PropiedadesRandom;


