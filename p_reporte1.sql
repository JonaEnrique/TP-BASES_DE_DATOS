WITH
Propiedad_espacio AS (
	SELECT Cama.Id_propiedad, SUM(Tipo_de_cama.Espacio) AS Espacio
	FROM Cama
	INNER JOIN Tipo_de_cama
	ON Cama.Id_tipo_de_cama = Tipo_de_cama.Id_tipo_de_cama
	GROUP BY Cama.Id_propiedad
),
Propiedad_dormitorio_banio AS (
	SELECT Dormitorio.Id_propiedad, COUNT(Dormitorio.Numero) AS Dormitorios, Propiedad_banio.Banios
	FROM Dormitorio
	INNER JOIN (
		SELECT Banio.Id_propiedad, COUNT(Banio.Numero) AS Banios
		FROM Banio
		GROUP BY Banio.Id_propiedad
	) AS Propiedad_banio
	ON Dormitorio.Id_propiedad = Propiedad_banio.Id_propiedad
	GROUP BY Dormitorio.Id_propiedad, Propiedad_banio.Banios
),
Propiedad_cama AS (
	SELECT Id_propiedad, COUNT(Numero_cama) AS Camas
	FROM Cama
	GROUP BY Id_propiedad
)
SELECT Propiedad.Nombre, Propiedad_dormitorio_banio.Banios, Propiedad_dormitorio_banio.Dormitorios, Propiedad_cama.Camas, Propiedad_espacio.Espacio
FROM Propiedad
INNER JOIN Propiedad_espacio
ON Propiedad.Id_propiedad = Propiedad_espacio.Id_propiedad
INNER JOIN Propiedad_dormitorio_banio
ON Propiedad_dormitorio_banio.Id_propiedad = Propiedad.Id_propiedad
INNER JOIN Propiedad_cama
ON Propiedad_cama.Id_propiedad = Propiedad.Id_propiedad