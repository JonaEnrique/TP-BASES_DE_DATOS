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