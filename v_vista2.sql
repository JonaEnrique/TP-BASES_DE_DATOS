CREATE OR ALTER VIEW v_vista2 AS
WITH ReferentesCTE AS (
    -- Caso base: Iniciamos con cada usuario que tiene un referente directo
    SELECT Id_usuario, Id_usuario_referente, 1 AS Nivel
    FROM Usuario
    WHERE Id_usuario_referente IS NOT NULL

    UNION ALL

    -- Parte recursiva: Para cada usuario, buscamos el siguiente referente y aumentamos el nivel
    SELECT rc.Id_usuario, u.Id_usuario_referente, rc.Nivel + 1
    FROM ReferentesCTE rc
    INNER JOIN Usuario u ON rc.Id_usuario_referente = u.Id_usuario
    WHERE u.Id_usuario_referente IS NOT NULL
)

-- Contamos el numero de ancestros para cada usuario
SELECT Id_usuario, MAX(Nivel) AS CantidadAncestros
FROM ReferentesCTE
GROUP BY Id_usuario;
