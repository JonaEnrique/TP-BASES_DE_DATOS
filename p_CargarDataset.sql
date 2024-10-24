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
--exec p_CargarDataset @archivo = '';--insertar path del excel