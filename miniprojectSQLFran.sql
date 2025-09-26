USE MusicStreamDB;

-- 1) Listar todas las canciones con el nombre de su álbum y artista.
SELECT c.cancion_id, c.titulo AS cancion, a.titulo AS album, ar.nombre AS artista
FROM canciones c
JOIN albumes a   ON c.album_id = a.album_id
JOIN artistas ar ON a.artista_id = ar.artista_id
ORDER BY ar.nombre, a.titulo, c.titulo;

-- 2) Mostrar usuarios y el plan al que están suscritos.
SELECT u.usuario_id, u.nombre, p.nombre AS plan, s.fecha_inicio, s.fecha_fin, s.estado
FROM usuarios u
LEFT JOIN suscripciones s ON s.usuario_id = u.usuario_id
LEFT JOIN planes p        ON p.plan_id    = s.plan_id
ORDER BY u.usuario_id;

-- 3) Ver playlists de cada usuario junto con cuántas canciones contiene.
SELECT u.nombre AS usuario, p.nombre AS playlist, COUNT(pc.cancion_id) AS num_canciones
FROM playlists p
JOIN usuarios u             ON u.usuario_id = p.usuario_id
LEFT JOIN playlist_canciones pc ON pc.playlist_id = p.playlist_id
GROUP BY u.nombre, p.nombre
ORDER BY u.nombre, num_canciones DESC;

-- 4) Listar historial de reproducción con nombre de usuario y canción.
SELECT hr.reproduccion_id, u.nombre AS usuario, c.titulo AS cancion, hr.fecha_reproduccion
FROM historial_reproduccion hr
JOIN usuarios u  ON hr.usuario_id = u.usuario_id
JOIN canciones c ON hr.cancion_id = c.cancion_id
ORDER BY hr.fecha_reproduccion;

-- 5) Mostrar canciones y si tienen “likes”, junto con el usuario que dio like.
SELECT c.titulo AS cancion, u.nombre AS usuario_like, l.fecha_like
FROM canciones c
LEFT JOIN likes l   ON l.cancion_id = c.cancion_id
LEFT JOIN usuarios u ON u.usuario_id = l.usuario_id
ORDER BY c.titulo, l.fecha_like;

-- 6) Usuarios que tienen más de 1 playlist.
SELECT u.usuario_id, u.nombre, COUNT(p.playlist_id) AS total_playlists
FROM usuarios u
JOIN playlists p ON p.usuario_id = u.usuario_id
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(p.playlist_id) > 1;

-- 7) Canciones con más reproducciones que el promedio global (columna num_reproducciones).
SELECT c.cancion_id, c.titulo, c.num_reproducciones
FROM canciones c
WHERE c.num_reproducciones > (SELECT AVG(num_reproducciones) FROM canciones)
ORDER BY c.num_reproducciones DESC;

-- 8) Artistas con al menos un álbum que tenga más de 3 canciones.
SELECT DISTINCT ar.artista_id, ar.nombre
FROM artistas ar
JOIN albumes a   ON a.artista_id = ar.artista_id
JOIN canciones c ON c.album_id = a.album_id
GROUP BY ar.artista_id, ar.nombre, a.album_id
HAVING COUNT(c.cancion_id) > 3;

-- 9) Usuarios que dieron like a la canción más popular (más reproducciones en historial).
SELECT DISTINCT u.usuario_id, u.nombre
FROM likes l
JOIN usuarios u ON u.usuario_id = l.usuario_id
WHERE l.cancion_id = (
  SELECT x.cancion_id
  FROM (
    SELECT hr.cancion_id
    FROM historial_reproduccion hr
    GROUP BY hr.cancion_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) x
);

-- 10) Canciones reproducidas por más de 2 usuarios distintos.
SELECT c.cancion_id, c.titulo, COUNT(DISTINCT hr.usuario_id) AS oyentes_unicos
FROM canciones c
JOIN historial_reproduccion hr ON hr.cancion_id = c.cancion_id
GROUP BY c.cancion_id, c.titulo
HAVING COUNT(DISTINCT hr.usuario_id) > 2;

-- 11) Top 5 canciones más reproducidas (historial).
SELECT c.cancion_id, c.titulo, COUNT(hr.reproduccion_id) AS reproducciones
FROM canciones c
JOIN historial_reproduccion hr ON hr.cancion_id = c.cancion_id
GROUP BY c.cancion_id, c.titulo
ORDER BY reproducciones DESC
LIMIT 5;

-- 12) Cantidad total de likes por artista.
SELECT ar.artista_id, ar.nombre, COUNT(l.like_id) AS likes_totales
FROM artistas ar
JOIN albumes a   ON a.artista_id = ar.artista_id
JOIN canciones c ON c.album_id = a.album_id
LEFT JOIN likes l ON l.cancion_id = c.cancion_id
GROUP BY ar.artista_id, ar.nombre
ORDER BY likes_totales DESC;

-- 13) Promedio de duración de canciones por género.
SELECT a.genero, SEC_TO_TIME(AVG(TIME_TO_SEC(c.duracion))) AS promedio_duracion
FROM canciones c
JOIN albumes a ON a.album_id = c.album_id
GROUP BY a.genero
ORDER BY promedio_duracion DESC;

-- 14) Número de usuarios suscritos a cada plan.
SELECT p.plan_id, p.nombre AS plan, COUNT(s.suscripcion_id) AS num_usuarios
FROM planes p
LEFT JOIN suscripciones s ON s.plan_id = p.plan_id
GROUP BY p.plan_id, p.nombre
ORDER BY num_usuarios DESC;

-- 15) El usuario con más reproducciones en el historial.
SELECT u.usuario_id, u.nombre, COUNT(hr.reproduccion_id) AS total_reproducciones
FROM usuarios u
JOIN historial_reproduccion hr ON hr.usuario_id = u.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY total_reproducciones DESC
LIMIT 1;

-- 16) Las 10 canciones más reproducidas.
SELECT c.cancion_id, c.titulo, COUNT(*) AS reproducciones
FROM historial_reproduccion hr
JOIN canciones c ON c.cancion_id = hr.cancion_id
GROUP BY c.cancion_id, c.titulo
ORDER BY reproducciones DESC
LIMIT 10;
 
-- 17) Usuarios que tienen plan activo (estado activa y sin fecha_fin o futura).
SELECT u.usuario_id, u.nombre, p.nombre AS plan, s.fecha_inicio, s.fecha_fin
FROM suscripciones s
JOIN usuarios u ON u.usuario_id = s.usuario_id
JOIN planes p   ON p.plan_id    = s.plan_id
WHERE s.estado = 'activa' AND (s.fecha_fin IS NULL OR s.fecha_fin >= CURDATE());
 
-- 18) Listar las playlists con su cantidad respectiva de canciones.
SELECT p.playlist_id, p.nombre, COUNT(pc.cancion_id) AS num_canciones
FROM playlists p
LEFT JOIN playlist_canciones pc ON pc.playlist_id = p.playlist_id
GROUP BY p.playlist_id, p.nombre
ORDER BY num_canciones DESC, p.nombre;
 
-- 19) Listar las canciones reproducidas el último mes.
SELECT DISTINCT c.cancion_id, c.titulo
FROM historial_reproduccion hr
JOIN canciones c ON c.cancion_id = hr.cancion_id
WHERE hr.fecha_reproduccion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
ORDER BY c.titulo;
 
-- 20) Usuarios que escucharon un mismo artista más de 2 veces.
SELECT u.usuario_id, u.nombre, ar.artista_id, ar.nombre AS artista, COUNT(*) AS reproducciones
FROM historial_reproduccion hr
JOIN usuarios u  ON u.usuario_id  = hr.usuario_id
JOIN canciones c ON c.cancion_id  = hr.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
JOIN artistas ar ON ar.artista_id = a.artista_id
GROUP BY u.usuario_id, u.nombre, ar.artista_id, ar.nombre
HAVING COUNT(*) > 2
ORDER BY reproducciones DESC;
 
-- 21) Canciones con duración mayor al promedio.
SELECT c.cancion_id, c.titulo, c.duracion
FROM canciones c
WHERE TIME_TO_SEC(c.duracion) > (
  SELECT AVG(TIME_TO_SEC(duracion)) FROM canciones
)
ORDER BY c.duracion DESC;
 
-- 22) Álbum con más reproducciones totales (por historial).
SELECT a.album_id, a.titulo, ar.nombre AS artista, COUNT(*) AS reproducciones
FROM historial_reproduccion hr
JOIN canciones c ON c.cancion_id = hr.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
JOIN artistas ar ON ar.artista_id = a.artista_id
GROUP BY a.album_id, a.titulo, ar.nombre
ORDER BY reproducciones DESC
LIMIT 1;
 
-- 23) Género musical más popular según reproducciones (por historial).
SELECT a.genero, COUNT(*) AS reproducciones
FROM historial_reproduccion hr
JOIN canciones c ON c.cancion_id = hr.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
GROUP BY a.genero
ORDER BY reproducciones DESC
LIMIT 1;
 
-- 24) Usuario con más likes dados.
SELECT u.usuario_id, u.nombre, COUNT(*) AS likes_dados
FROM likes l
JOIN usuarios u ON u.usuario_id = l.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY likes_dados DESC
LIMIT 1;

-- 25) Canciones que nunca han sido reproducidas.
SELECT c.cancion_id, c.titulo
FROM canciones c
LEFT JOIN historial_reproduccion hr ON hr.cancion_id = c.cancion_id
WHERE hr.cancion_id IS NULL
ORDER BY c.titulo;
 
-- 26) Playlists con canciones de más de 2 géneros diferentes.
SELECT p.playlist_id, p.nombre, COUNT(DISTINCT a.genero) AS generos_distintos
FROM playlists p
JOIN playlist_canciones pc ON pc.playlist_id = p.playlist_id
JOIN canciones c ON c.cancion_id = pc.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
GROUP BY p.playlist_id, p.nombre
HAVING COUNT(DISTINCT a.genero) > 2;
 
-- 27) Usuarios que escucharon canciones de al menos 3 artistas distintos.
SELECT u.usuario_id, u.nombre, COUNT(DISTINCT ar.artista_id) AS artistas_distintos
FROM historial_reproduccion hr
JOIN usuarios u  ON u.usuario_id  = hr.usuario_id
JOIN canciones c ON c.cancion_id  = hr.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
JOIN artistas ar ON ar.artista_id = a.artista_id
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(DISTINCT ar.artista_id) >= 3
ORDER BY artistas_distintos DESC;
 
-- 28) Ranking de artistas por número de oyentes únicos.
SELECT ar.artista_id, ar.nombre, COUNT(DISTINCT hr.usuario_id) AS oyentes_unicos
FROM historial_reproduccion hr
JOIN canciones c ON c.cancion_id  = hr.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
JOIN artistas ar ON ar.artista_id = a.artista_id
GROUP BY ar.artista_id, ar.nombre
ORDER BY oyentes_unicos DESC, ar.nombre;
 
-- 29) Plan con mayor ingreso generado (precio * suscriptores activos).
SELECT p.nombre AS plan, p.precio, COUNT(*) AS suscriptores_activos,
       (p.precio * COUNT(*)) AS ingreso_estimado
FROM suscripciones s
JOIN planes p ON p.plan_id = s.plan_id
WHERE s.estado = 'activa' AND (s.fecha_fin IS NULL OR s.fecha_fin >= CURDATE())
GROUP BY p.plan_id, p.nombre, p.precio
ORDER BY ingreso_estimado DESC
LIMIT 1;
 
-- 30) Canciones agregadas a playlists en los últimos 7 días.
SELECT c.cancion_id, c.titulo, p.nombre AS playlist, pc.fecha_agregacion
FROM playlist_canciones pc
JOIN canciones c ON c.cancion_id = pc.cancion_id
JOIN playlists p ON p.playlist_id = pc.playlist_id
WHERE pc.fecha_agregacion >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY pc.fecha_agregacion DESC;
 
 SELECT c.cancion_id, c.titulo, a.album_id, a.titulo AS album, ar.artista_id, ar.nombre AS artista
FROM canciones c
JOIN albumes a ON c.album_id = a.album_id
JOIN artistas ar ON a.artista_id = ar.artista_id
LIMIT 20;
-- 31) Los 5 artistas con mayor cantidad de canciones en la plataforma
SELECT ar.artista_id, ar.nombre, COUNT(c.cancion_id) AS total_canciones
FROM artistas ar
JOIN albumes a   ON a.artista_id   = ar.artista_id
JOIN canciones c ON c.album_id     = a.album_id
GROUP BY ar.artista_id, ar.nombre
ORDER BY total_canciones DESC, ar.nombre
LIMIT 5;
 
 
 -- 32) Álbumes lanzados después de 2020 junto con su artista.
SELECT a.album_id, a.titulo, a.fecha_lanzamiento, ar.nombre AS artista
FROM albumes a
JOIN artistas ar ON ar.artista_id = a.artista_id
WHERE a.fecha_lanzamiento >= '2021-01-01'
ORDER BY a.fecha_lanzamiento DESC;
 
-- 33) Usuarios que nunca han creado una playlist
SELECT u.usuario_id, u.nombre
FROM usuarios u
WHERE NOT EXISTS (
    SELECT 1
    FROM playlists p
    WHERE p.usuario_id = u.usuario_id
)
ORDER BY u.nombre;
 
-- 34) Canciones que aparecen en más de 2 playlists distintas.
SELECT c.cancion_id, c.titulo, COUNT(DISTINCT pc.playlist_id) AS n_playlists
FROM canciones c
JOIN playlist_canciones pc ON pc.cancion_id = c.cancion_id
GROUP BY c.cancion_id, c.titulo
HAVING COUNT(DISTINCT pc.playlist_id) > 2
ORDER BY n_playlists DESC, c.titulo;
 
-- 35) Artistas que tienen canciones con más de 1,000 reproducciones (columna num_reproducciones).
SELECT DISTINCT ar.artista_id, ar.nombre
FROM artistas ar
JOIN albumes a ON a.artista_id = ar.artista_id
JOIN canciones c ON c.album_id = a.album_id
WHERE c.num_reproducciones > 1000
ORDER BY ar.nombre;
 
-- 36) Top 3 de usuarios con más canciones reproducidas en total.
SELECT u.usuario_id, u.nombre, COUNT(*) AS reproducciones
FROM historial_reproduccion hr
JOIN usuarios u ON u.usuario_id = hr.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY reproducciones DESC
LIMIT 3;
 
-- 37) Playlists que contienen al menos una canción de cada género musical existente.
SELECT p.playlist_id, p.nombre
FROM playlists p
JOIN playlist_canciones pc ON pc.playlist_id = p.playlist_id
JOIN canciones c ON c.cancion_id = pc.cancion_id
JOIN albumes a   ON a.album_id    = c.album_id
GROUP BY p.playlist_id, p.nombre
HAVING COUNT(DISTINCT a.genero) = (
  SELECT COUNT(DISTINCT a2.genero)
  FROM albumes a2
  JOIN canciones c2 ON c2.album_id = a2.album_id
);
 
-- 38) Usuarios que tienen una suscripción vencida.
SELECT u.usuario_id, u.nombre, p.nombre AS plan, s.fecha_inicio, s.fecha_fin
FROM suscripciones s
JOIN usuarios u ON u.usuario_id = s.usuario_id
JOIN planes p   ON p.plan_id    = s.plan_id
WHERE s.fecha_fin IS NOT NULL AND s.fecha_fin < CURDATE();
 
-- 39) Canciones que recibieron likes de más de 3 usuarios diferentes.
SELECT c.cancion_id, c.titulo, COUNT(DISTINCT l.usuario_id) AS usuarios_like
FROM canciones c
JOIN likes l ON l.cancion_id = c.cancion_id
GROUP BY c.cancion_id, c.titulo
HAVING COUNT(DISTINCT l.usuario_id) > 3
ORDER BY usuarios_like DESC, c.titulo;
 
-- 40) Álbumes con la duración promedio de sus canciones.
SELECT a.album_id, a.titulo, SEC_TO_TIME(AVG(TIME_TO_SEC(c.duracion))) AS duracion_promedio
FROM albumes a
JOIN canciones c ON c.album_id = a.album_id
GROUP BY a.album_id, a.titulo
ORDER BY AVG(TIME_TO_SEC(c.duracion)) DESC;

-- 41) Artistas que no tienen ningún álbum registrado.
SELECT ar.artista_id, ar.nombre
FROM artistas ar
LEFT JOIN albumes a ON a.artista_id = ar.artista_id
WHERE a.album_id IS NULL
ORDER BY ar.nombre;
-- 42) Usuarios que nunca han dado like a una canción.
SELECT u.usuario_id, u.nombre
FROM usuarios u
LEFT JOIN likes l ON l.usuario_id = u.usuario_id
WHERE l.like_id IS NULL
ORDER BY u.nombre;
-- 43) Mostrar las canciones más reproducidas por cada usuario (una por usuario, método sin ventanas).
SELECT t.usuario_id, u.nombre, t.cancion_id, c.titulo AS cancion, t.reproducciones
FROM (
  SELECT hr.usuario_id, hr.cancion_id, COUNT(*) AS reproducciones
  FROM historial_reproduccion hr
  GROUP BY hr.usuario_id, hr.cancion_id
) t
JOIN (
  SELECT usuario_id, MAX(reproducciones) AS max_rep
  FROM (
    SELECT hr.usuario_id, hr.cancion_id, COUNT(*) AS reproducciones
    FROM historial_reproduccion hr
    GROUP BY hr.usuario_id, hr.cancion_id
  ) z
  GROUP BY usuario_id
) m ON m.usuario_id = t.usuario_id AND m.max_rep = t.reproducciones
JOIN usuarios u  ON u.usuario_id  = t.usuario_id
JOIN canciones c ON c.cancion_id  = t.cancion_id
ORDER BY u.usuario_id;
-- 44) Top 5 de canciones más agregadas a playlists.
SELECT c.cancion_id, c.titulo, COUNT(*) AS veces_agregada
FROM playlist_canciones pc
JOIN canciones c ON c.cancion_id = pc.cancion_id
GROUP BY c.cancion_id, c.titulo
ORDER BY veces_agregada DESC, c.titulo
LIMIT 5;
-- 45) Plan con menor número de usuarios suscritos.
SELECT p.nombre AS plan, COUNT(s.suscripcion_id) AS usuarios
FROM planes p
LEFT JOIN suscripciones s ON s.plan_id = p.plan_id
GROUP BY p.plan_id, p.nombre
ORDER BY usuarios ASC, p.nombre
LIMIT 1;
-- 46) Canciones reproducidas por usuarios de un país específico (ej.: México).
SELECT DISTINCT c.cancion_id, c.titulo
FROM historial_reproduccion hr
JOIN usuarios u  ON u.usuario_id = hr.usuario_id
JOIN canciones c ON c.cancion_id = hr.cancion_id
WHERE u.pais = 'México'
ORDER BY c.titulo;
-- 47) Artistas cuyo género principal coincide con el género más popular en reproducciones.
SELECT ar.artista_id, ar.nombre, ar.genero
FROM artistas ar
WHERE ar.genero = (
  SELECT g.genero
  FROM (
    SELECT a.genero, COUNT(*) AS rep
    FROM historial_reproduccion hr
    JOIN canciones c ON c.cancion_id = hr.cancion_id
    JOIN albumes a   ON a.album_id    = c.album_id
    GROUP BY a.genero
    ORDER BY rep DESC
    LIMIT 1
  ) g
)
ORDER BY ar.nombre;
-- 48) Usuarios que tienen al menos una playlist con más de 5 canciones
SELECT DISTINCT u.usuario_id, u.nombre
FROM usuarios u
JOIN playlists p ON p.usuario_id = u.usuario_id
JOIN playlist_canciones pc ON pc.playlist_id = p.playlist_id
GROUP BY u.usuario_id, u.nombre, p.playlist_id
HAVING COUNT(pc.cancion_id) > 5
ORDER BY u.nombre;
-- 49) Usuarios que comparten canciones en común en sus playlists (pares únicos).
SELECT DISTINCT u1.usuario_id AS usuario_a, u1.nombre AS nombre_a,
                u2.usuario_id AS usuario_b, u2.nombre AS nombre_b,
                c.titulo AS cancion_en_comun
FROM playlists p1
JOIN playlist_canciones pc1 ON pc1.playlist_id = p1.playlist_id
JOIN canciones c            ON c.cancion_id   = pc1.cancion_id
JOIN playlists p2           ON p2.usuario_id  <> p1.usuario_id
JOIN playlist_canciones pc2 ON pc2.playlist_id = p2.playlist_id AND pc2.cancion_id = pc1.cancion_id
JOIN usuarios u1 ON u1.usuario_id = p1.usuario_id
JOIN usuarios u2 ON u2.usuario_id = p2.usuario_id
WHERE u1.usuario_id < u2.usuario_id
ORDER BY u1.usuario_id, u2.usuario_id, c.titulo;
-- 50) Artistas que tienen canciones en playlists de más de 5 usuarios diferentes.
SELECT ar.artista_id, ar.nombre, COUNT(DISTINCT p.usuario_id) AS usuarios_distintos
FROM artistas ar
JOIN albumes a   ON a.artista_id  = ar.artista_id
JOIN canciones c ON c.album_id    = a.album_id
JOIN playlist_canciones pc ON pc.cancion_id = c.cancion_id
JOIN playlists p          ON p.playlist_id  = pc.playlist_id
GROUP BY ar.artista_id, ar.nombre
HAVING COUNT(DISTINCT p.usuario_id) > 5
ORDER BY usuarios_distintos DESC, ar.nombre;