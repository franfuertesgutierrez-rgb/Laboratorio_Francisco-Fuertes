-- 1. Selecciona todos los clientes.
SELECT * FROM Clientes;

-- 2. Selecciona todos los empleados.
SELECT * FROM Empleados;

-- 3. Selecciona todas las tiendas.
SELECT * FROM Tiendas;

-- 4. Selecciona todas las prendas de ropa.
SELECT * FROM Prendas;

-- 5. Busca clientes cuyo nombre comience con la letra "L".
SELECT * FROM Clientes
WHERE nombre_cliente LIKE 'L%';

-- 6. Cuenta cuántos clientes hay en la base de datos.
SELECT COUNT(*) AS total_clientes FROM Clientes;

-- 7. Selecciona las compras realizadas después del 1 de mayo de 2023.
SELECT * FROM Compras
WHERE fecha_compra > '2023-05-01';

-- 8. Actualiza el correo electrónico de un cliente específico (EJ: id = 2).
UPDATE Clientes
SET email_cliente = 'nuevo.email+id2@example.com'
WHERE id_cliente = 2;  -- usa PK -> OK con safe mode

-- 9. Elimina un cliente por su ID (EJ: id = 999).
-- Primero, borra sus compras usando PK de Compras (id_compra).
DELETE FROM Compras
WHERE id_compra IN (
  SELECT id_compra FROM (
    SELECT id_compra FROM Compras WHERE id_cliente = 999
  ) AS t
);

DELETE FROM Clientes
WHERE id_cliente = 999;  -- usa PK -> OK

-- 10. Selecciona las prendas de color Negro.
SELECT * FROM Prendas
WHERE color = 'Negro';

-- 11. Selecciona todas las tiendas que hay en Madrid.
SELECT * FROM Tiendas
WHERE ciudad = 'Madrid';

-- 12. Cuenta cuántas prendas tienen un precio mayor a 50.
SELECT COUNT(*) AS prendas_caras
FROM Prendas
WHERE precio > 50;

-- 13. Selecciona los empleados que trabajan en la tienda con ID 1.
SELECT * FROM Empleados
WHERE tienda_id = 1;

-- 14. Busca clientes cuyo nombre contenga "Andrés".
SELECT * FROM Clientes
WHERE nombre_cliente LIKE '%Andrés%';

-- 15. Selecciona las compras realizadas por el cliente con ID 2.
SELECT * FROM Compras
WHERE id_cliente = 2;

-- 16. Elimina todas las compras cuyo monto sea menor a 30. (PK-friendly)
DELETE FROM Compras
WHERE id_compra IN (
  SELECT id_compra FROM (
    SELECT id_compra FROM Compras WHERE monto_total < 30
  ) AS t
);

-- 17. Selecciona las prendas cuyo precio esté entre 20 y 40 (incluidos).
SELECT * FROM Prendas
WHERE precio BETWEEN 20 AND 40;

-- 18. Busca empleados cuyo nombre contenga la letra "a".
SELECT * FROM Empleados
WHERE nombre_empleado LIKE '%a%';

-- 19. Selecciona las 5 prendas más caras.
SELECT * FROM Prendas
ORDER BY precio DESC
LIMIT 5;

-- 20. Selecciona las compras de un cliente con un monto superior a 75 (EJ: id_cliente = 1).
SELECT * FROM Compras
WHERE id_cliente = 1
  AND monto_total > 75;

-- 21. Selecciona las prendas de talla M.
SELECT * FROM Prendas
WHERE talla = 'M';

-- 22. Actualiza la talla de una prenda específica por su ID (EJ: id_prenda = 1).
UPDATE Prendas
SET talla = 'L'
WHERE id_prenda = 1;  -- usa PK -> OK

-- 23. Selecciona todos los empleados contratados después del 1 de enero de 2022.
SELECT * FROM Empleados
WHERE fecha_contratacion > '2022-01-01';

-- 24. Busca tiendas en "Barcelona".
SELECT * FROM Tiendas
WHERE ciudad = 'Barcelona';

-- 25. Elimina un empleado por su ID (EJ: id_empleado = 999).
DELETE FROM Empleados
WHERE id_empleado = 999;  -- usa PK -> OK

-- 26. Selecciona las compras que se realizaron antes del 1 de julio de 2023.
SELECT * FROM Compras
WHERE fecha_compra < '2023-07-01';

-- 27. Busca prendas cuyo nombre (tipo_prenda) termine en "eta".
SELECT * FROM Prendas
WHERE tipo_prenda LIKE '%eta';

-- 28. Selecciona los clientes que no tengan un email registrado con "hotmail".
SELECT * FROM Clientes
WHERE email_cliente NOT LIKE '%hotmail%';

-- 29. Cuenta cuántas compras se realizaron en septiembre de 2023.
SELECT COUNT(*) AS compras_sep_2023
FROM Compras
WHERE fecha_compra BETWEEN '2023-09-01' AND '2023-09-30';

-- 30. Actualiza la dirección de una tienda por su ID (EJ: id_tienda = 1).
UPDATE Tiendas
SET direccion = 'Paseo de la Castellana, 100'
WHERE id_tienda = 1;  -- usa PK -> OK

-- 31. Selecciona las prendas que sean camisetas.
SELECT * FROM Prendas
WHERE tipo_prenda = 'Camiseta';

-- 32. Elimina todas las prendas cuyo precio sea menor a 20. (PK-friendly)
DELETE FROM Prendas
WHERE id_prenda IN (
  SELECT id_prenda
  FROM (
    SELECT id_prenda
    FROM Prendas
    WHERE precio < 20
  ) AS tmp
);

-- 33. Selecciona todas las tiendas y ordénalas por ciudad.
SELECT * FROM Tiendas
ORDER BY ciudad ASC, nombre_tienda ASC;

-- 34. Selecciona los empleados que sean vendedores.
SELECT * FROM Empleados
WHERE puesto = 'Vendedor';

-- 35. Cuenta cuántas prendas son de color blanco.
SELECT COUNT(*) AS prendas_blancas
FROM Prendas
WHERE color = 'Blanco';

-- 36. Selecciona los clientes que tengan nombres de más de 10 caracteres.
SELECT *
FROM Clientes
WHERE LENGTH(nombre_cliente) > 10;

-- 37. Busca compras cuyo monto total esté entre 50 y 100 (incluidos).
SELECT *
FROM Compras
WHERE monto_total BETWEEN 50 AND 100;

-- 38. Selecciona las 3 compras más recientes.
SELECT *
FROM Compras
ORDER BY fecha_compra DESC, id_compra DESC
LIMIT 3;

/* === Contexto === */
USE ZaraBusiness;

/* ========= 39 =========
   Asegura que exista la tabla Cursos y algunos datos de ejemplo con "Digital"
*/
CREATE TABLE IF NOT EXISTS Cursos (
  id_curso INT AUTO_INCREMENT PRIMARY KEY,
  nombre_curso VARCHAR(100) NOT NULL,
  duracion INT,
  precio DECIMAL(10,2),
  UNIQUE KEY uq_curso_nombre (nombre_curso)
);

INSERT IGNORE INTO Cursos (nombre_curso, duracion, precio) VALUES
('Marketing Digital', 40, 200.00),
('Transformación Digital', 60, 350.00);

/* Consulta 39 */
SELECT *
FROM Cursos
WHERE nombre_curso LIKE '%Digital%';


/* ========= 40 =========
   Agrupa prendas por color y cuenta cuántas hay
*/
SELECT color, COUNT(*) AS total
FROM Prendas
GROUP BY color
ORDER BY total DESC;


/* ========= 41 =========
   Añade dos tiendas más en Madrid, evitando duplicados
*/
INSERT INTO Tiendas (nombre_tienda, direccion, ciudad, pais)
SELECT 'Zara Castellana', 'Paseo de la Castellana, 200', 'Madrid', 'España'
WHERE NOT EXISTS (SELECT 1 FROM Tiendas WHERE nombre_tienda = 'Zara Castellana');

INSERT INTO Tiendas (nombre_tienda, direccion, ciudad, pais)
SELECT 'Zara Puerta del Sol', 'Puerta del Sol, 1', 'Madrid', 'España'
WHERE NOT EXISTS (SELECT 1 FROM Tiendas WHERE nombre_tienda = 'Zara Puerta del Sol');


/* ========= 42 =========
   Miguel -> Micaela, en modo seguro (usa PK en WHERE)
*/
UPDATE Clientes
SET nombre_cliente = 'Micaela Torres',
    email_cliente  = 'micaela.torres@email.com'
WHERE id_cliente IN (
  SELECT id_cliente FROM (
    SELECT id_cliente
    FROM Clientes
    WHERE nombre_cliente = 'Miguel Torres'
  ) AS t
);
