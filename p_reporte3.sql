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


GO
exec p_reporte3 '2024-10-01', '2024-10-05', 5;