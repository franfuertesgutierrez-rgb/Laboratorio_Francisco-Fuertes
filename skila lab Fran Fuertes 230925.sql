
-- Obtener todos los datos de actor, film y customer
SELECT * FROM actor;
SELECT * FROM film;
SELECT * FROM customer;

-- Obtener títulos de películas
SELECT title FROM film;

-- Lista única de idiomas con alias language
SELECT DISTINCT name AS language
FROM language;

-- 5.1 ¿Cuántas tiendas tiene la empresa?
SELECT COUNT(*) AS total_stores
FROM store;

-- 5.2 ¿Cuántos empleados tiene la empresa?
SELECT COUNT(*) AS total_employees
FROM staff;

-- 5.3 Nombres de los empleados
SELECT first_name, last_name
FROM staff;

/* Más instrucciones */

-- Actores con nombre Scarlett
SELECT * FROM actor
WHERE first_name = 'SCARLETT';

-- Actores con apellido Johansson
SELECT * FROM actor
WHERE last_name = 'JOHANSSON';

-- ¿Cuántas películas están disponibles para alquilar?
SELECT COUNT(*) AS available_films
FROM inventory;

-- ¿Cuántas películas se han alquilado?
SELECT COUNT(*) AS rented_films
FROM rental;

-- Período de alquiler más corto y más largo
SELECT MIN(rental_duration) AS min_rental_period,
       MAX(rental_duration) AS max_rental_period
FROM film;

-- Duración más corta y más larga de una película
SELECT MIN(length) AS min_duration,
       MAX(length) AS max_duration
FROM film;

-- Duración media de una película
SELECT AVG(length) AS avg_duration
FROM film;

-- Duración promedio en formato horas:minutos
SELECT FLOOR(AVG(length) / 60) AS hours,
       ROUND(AVG(length) % 60) AS minutes
FROM film;

-- ¿Cuántas películas duran más de 3 horas? (180 min)
SELECT COUNT(*) AS films_over_3h
FROM film
WHERE length > 180;

-- Formatear nombre y correo de clientes
SELECT CONCAT(first_name, ' ', UPPER(last_name), ' - ', email) AS formatted
FROM customer;

-- Duración del título más largo de una película
SELECT MAX(CHAR_LENGTH(title)) AS longest_title_length
FROM film;
