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

GO