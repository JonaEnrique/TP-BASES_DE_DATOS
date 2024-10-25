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

exec p_reporte1