--SERVICIO (ID_SERVICIO PK (INT), DESCRIPCION (VARCHAR))
--TIENE_SERVICIO (ID_SERVICIO PK+FK (INT) , ID_PROPIEDAD PK+FK (INT))
DECLARE @cantidad INT = 1;
DECLARE @descripcionServicio VARCHAR(100) = 'Servicio ';

IF OBJECT_ID('tempdb..#Propiedades_random') IS NOT NULL
    DROP TABLE #Propiedades_random;
IF OBJECT_ID('tempdb..#Servicios_random') IS NOT NULL
    DROP TABLE #Servicios_random;

WHILE (@cantidad < 41)
BEGIN
	
	INSERT INTO Servicio(Descripcion)
	VALUES (
		@descripcionServicio + CAST(@cantidad AS CHAR)
	)

	SET @cantidad += 1;

END


/*
SELECT *
From Servicio

DELETE FROM Servicio;
DROP TABLE Tiene_servicio
DROP TABLE Servicio;
*/

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


/*
select *
from Tiene_servicio
where Id_propiedad=1460195
DELETE FROM Tiene_servicio;
*/