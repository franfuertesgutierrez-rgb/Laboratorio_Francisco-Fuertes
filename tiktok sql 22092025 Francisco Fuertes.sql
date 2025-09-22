SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;

-- -----------------------------------------------------
-- Table `usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_usuario` INT NOT NULL,
  `nombre_usuario` VARCHAR(255) NOT NULL,
  `correo_electronico` VARCHAR(255) NOT NULL,
  `fecha_registro` DATE NULL,
  `pais_origen` GEOMETRY NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE (`correo_electronico`),
  UNIQUE (`nombre_usuario`)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `videos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `videos` (
  `idvideo` INT NOT NULL,
  `descripcion` TEXT NULL,
  `fecha_publicacion` DATETIME NULL,
  `duracion_segundos` TIME NULL,
  `usuarios_id_usuario` INT NOT NULL,
  PRIMARY KEY (`idvideo`),
  INDEX (`usuarios_id_usuario`),
  CONSTRAINT `fk_videos_usuarios`
    FOREIGN KEY (`usuarios_id_usuario`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `comentarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `comentarios` (
  `id_comentario` INT NOT NULL,
  `videos_idvideo` INT NOT NULL,
  `usuarios_id_usuario` INT NOT NULL,
  `texto_comentario` TEXT NULL,
  `fecha_comentario` DATETIME NULL,
  PRIMARY KEY (`id_comentario`),
  INDEX (`videos_idvideo`),
  INDEX (`usuarios_id_usuario`),
  CONSTRAINT `fk_comentarios_videos`
    FOREIGN KEY (`videos_idvideo`)
    REFERENCES `videos` (`idvideo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comentarios_usuarios`
    FOREIGN KEY (`usuarios_id_usuario`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `likes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `likes` (
  `id_like` INT NOT NULL,
  `videos_idvideo` INT NOT NULL,
  `comentarios_id_comentario` INT NULL,
  `usuarios_id_usuario` INT NOT NULL,
  `fecha_like` DATETIME NULL,
  PRIMARY KEY (`id_like`),
  INDEX (`videos_idvideo`),
  INDEX (`comentarios_id_comentario`),
  INDEX (`usuarios_id_usuario`),
  CONSTRAINT `fk_likes_videos`
    FOREIGN KEY (`videos_idvideo`)
    REFERENCES `videos` (`idvideo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_likes_comentarios`
    FOREIGN KEY (`comentarios_id_comentario`)
    REFERENCES `comentarios` (`id_comentario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_likes_usuarios`
    FOREIGN KEY (`usuarios_id_usuario`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `seguidores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `seguidores` (
  `id_seguidor` INT NOT NULL,
  `id_usuario_seguidor` INT NOT NULL,
  `id_usuario_seguido` INT NOT NULL,
  `fecha_seguimiento` DATETIME NULL,
  PRIMARY KEY (`id_seguidor`),
  INDEX (`id_usuario_seguidor`),
  INDEX (`id_usuario_seguido`),
  CONSTRAINT `fk_seguidores_seguidor`
    FOREIGN KEY (`id_usuario_seguidor`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_seguidores_seguido`
    FOREIGN KEY (`id_usuario_seguido`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------
-- Consultas
-- -----------------------------
-- 1. Todos los usuarios
SELECT * FROM usuarios;

-- 2. Todos los videos
SELECT * FROM videos;

-- 3. Comentarios con usuario y video
SELECT * 
FROM comentarios c
JOIN usuarios u ON c.usuarios_id_usuario = u.id_usuario
JOIN videos v ON c.videos_idvideo = v.idvideo;

-- 4. Likes con usuario y video
SELECT * 
FROM likes l
JOIN usuarios u ON l.usuarios_id_usuario = u.id_usuario
JOIN videos v ON l.videos_idvideo = v.idvideo;

-- 5. Seguimientos
SELECT * 
FROM seguidores s
JOIN usuarios u1 ON s.id_usuario_seguidor = u1.id_usuario
JOIN usuarios u2 ON s.id_usuario_seguido = u2.id_usuario;

-- 6. Total de videos por usuario
SELECT u.*, COALESCE(vcount.total_videos,0) AS total_videos
FROM usuarios u
LEFT JOIN (
  SELECT usuarios_id_usuario, COUNT(*) AS total_videos
  FROM videos
  GROUP BY usuarios_id_usuario
) vcount ON u.id_usuario = vcount.usuarios_id_usuario;

-- 7. Total de comentarios por video
SELECT v.*, COALESCE(ccount.total_comentarios,0) AS total_comentarios
FROM videos v
LEFT JOIN (
  SELECT videos_idvideo, COUNT(*) AS total_comentarios
  FROM comentarios
  GROUP BY videos_idvideo
) ccount ON v.idvideo = ccount.videos_idvideo;

-- 8. Usuario que ha dado más likes
SELECT * 
FROM (
  SELECT u.id_usuario, u.nombre_usuario, COUNT(l.id_like) AS total_likes_dados
  FROM usuarios u
  JOIN likes l ON u.id_usuario = l.usuarios_id_usuario
  GROUP BY u.id_usuario, u.nombre_usuario
  ORDER BY total_likes_dados DESC
  LIMIT 1
) top_likeador;
