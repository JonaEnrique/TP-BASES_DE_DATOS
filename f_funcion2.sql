CREATE OR ALTER FUNCTION f_funcion2 (@contrasenia NVARCHAR(20))
RETURNS BIT
AS
BEGIN
	IF (@contrasenia is null)
		RETURN 0;
	-- minimo 8 caracteres
	IF (LEN(@contrasenia) < 8)
		RETURN 0;

	-- minimo una mayuscula
	IF (NOT @contrasenia LIKE '%[A-Z]%')
		RETURN 0;

	-- minimo una minuscula
	IF (NOT @contrasenia LIKE '%[a-z]%')
		RETURN 0;

	-- minimo un numero
	IF (NOT @contrasenia LIKE '%[0-9]%')
		RETURN 0;

	-- minimo un caracter especial
	IF (NOT @contrasenia LIKE '%[^a-zA-Z0-9]%')
		RETURN 0;

	RETURN 1;

END;

