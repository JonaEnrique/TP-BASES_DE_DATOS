
--DROP PROCEDURE p_CrearDB
CREATE PROCEDURE p_CrearDB (@borrar_si_existe bit)
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
Create Database Airbnb
USE master;
GO
DROP DATABASE Airbnb;
*/