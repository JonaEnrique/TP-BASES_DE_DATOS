--Funcion para formatear nombres 
--Ej Nombres de ususario, cambiar ej de ABEl LopEs __> Abel Lopez 

--DROP FUNCTION f_funcion1

CREATE FUNCTION dbo.f_funcion1 (@Nombre NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Resultado NVARCHAR(100);
    
    -- Convierte el nombre a minúsculas
    SET @Resultado = LOWER(@Nombre);
    
    -- Capitaliza solo la primera letra de cada palabra
    SET @Resultado = (SELECT STRING_AGG(
                            CASE 
                                -- Si la palabra empieza con una letra  a-z, pone en MAYUSCULA la primera letra, y el resto en minuscula
                                WHEN value LIKE '[a-z]%' 
                                THEN UPPER(LEFT(value, 1)) + SUBSTRING(value, 2, LEN(value))
                                -- Si no empieza con una letra, no cambia la palabra
                                ELSE value 
                            END, 
                            ' ')
                      FROM STRING_SPLIT(@Resultado, ' '));

    RETURN @Resultado;
END;

/*
SELECT  dbo.f_funcion1('USuaRio JuanTo') as NOMBREFORMATEADO
SELECT  dbo.f_funcion1('UsUaRio jauN123 ') as NOMBREFORMATEADO
*/

/*
UPDATE Usuario
SET Nombre = dbo.f_funcion1(Nombre);
*/

/*
Select Nombre
From Usuario
*/
