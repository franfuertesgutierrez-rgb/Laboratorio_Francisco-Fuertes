SELECT ar.nombre AS artista,
       COUNT(hr.reproduccion_id) AS total_reproducciones
FROM historial_reproduccion hr
INNER JOIN canciones c ON hr.cancion_id = c.cancion_id
INNER JOIN albumes a ON c.album_id = a.album_id
INNER JOIN artistas ar ON a.artista_id = ar.artista_id
GROUP BY ar.artista_id, ar.nombre
HAVING COUNT(hr.reproduccion_id) >
       (SELECT AVG(reproducciones_por_artista)
        FROM (
            SELECT COUNT(hr2.reproduccion_id) AS reproducciones_por_artista
            FROM historial_reproduccion hr2
            INNER JOIN canciones c2 ON hr2.cancion_id = c2.cancion_id
            INNER JOIN albumes a2 ON c2.album_id = a2.album_id
            GROUP BY a2.artista_id
        ) subquery);
