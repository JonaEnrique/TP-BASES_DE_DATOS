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