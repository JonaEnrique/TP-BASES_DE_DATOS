CREATE OR ALTER VIEW v_vista2 AS
WITH ReferentesCTE AS (
    -- Caso base: Iniciamos con cada usuario con 1 ancestro si tiene un referente directo
    SELECT Id_usuario, Id_usuario_referente, 0 AS Nivel
    FROM Usuario
    WHERE Id_usuario_referente IS NOT NULL

    UNION ALL

    -- Parte recursiva: Para cada usuario en ReferentesCTE, buscamos su referente y sumamos 1 al nivel
    SELECT u.Id_usuario, u.Id_usuario_referente, rc.Nivel + 1
    FROM Usuario u
    INNER JOIN ReferentesCTE rc ON u.Id_usuario = rc.Id_usuario_referente
)

-- Contamos el número de ancestros para cada usuario
SELECT Id_usuario, MAX(Nivel) AS CantidadAncestros
FROM ReferentesCTE
GROUP BY Id_usuario
--ORDER BY UsuarioID;

--SELECT * FROM v_vista2 ORDER BY Id_usuario
--SELECT * FROM Usuario