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

DECLARE @propiedad INT;
SET @propiedad = (Select TOP 1 p.Id_propiedad from Propiedad p where p.Id_propiedad>5000 );

EXEC p_reporte4
    @IdPropiedad = -@propiedad,  -- ID de la propiedad desde la cual calcular el radio
    @Radio = 100;         -- Radio en metros