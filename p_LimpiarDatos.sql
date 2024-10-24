CREATE PROCEDURE p_LimpiarDatos
AS
BEGIN

	DELETE FROM Cama;
	DELETE FROM Tipo_de_cama;
	DELETE FROM Dormitorio;
	DELETE FROM Banio;
	DELETE FROM Habitacion;
	DELETE FROM Resenia;
	DELETE FROM Fecha_reservada;
	DELETE FROM Reserva;
	DELETE FROM Tiene_servicio;
	DELETE FROM Servicio;
	DELETE FROM Propiedad;
	DELETE FROM Localidad;
	DELETE FROM Tipo_de_propiedad;
	DELETE FROM Usuario;
	DELETE FROM Categoria;

END;