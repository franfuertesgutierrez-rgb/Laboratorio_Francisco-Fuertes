-- soluciones_lab_classicmodels.sql
-- Asegúrate de haber creado y cargado la BD con tus scripts antes.
USE classicmodels;

-- Opcional (si Workbench te frena los UPDATE con WHERE):
-- SET SQL_SAFE_UPDATES = 0;

/* =========================
   EJERCICIO 1
   ========================= */

-- 1.1) Contactos de oficina (código + teléfono)
SELECT officeCode, phone
FROM offices
ORDER BY officeCode;

-- 1.2) Empleados con email que termina en ".es"
SELECT employeeNumber, firstName, lastName, email
FROM employees
WHERE email LIKE '%.es'
ORDER BY lastName, firstName;

-- 1.3) Clientes sin "state"
SELECT customerNumber, customerName, country, state
FROM customers
WHERE state IS NULL OR TRIM(state) = '';

-- 1.4) Pagos > 20,000
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 20000
ORDER BY amount DESC;

-- 1.5) Pagos > 20,000 realizados en 2005
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 20000
  AND YEAR(paymentDate) = 2005
ORDER BY amount DESC;

-- 1.6) Filas únicas de orderdetails por productCode
-- (a) Solo códigos distintos
SELECT DISTINCT productCode
FROM orderdetails
ORDER BY productCode;

-- (b) Una fila por productCode con el precio máximo
SELECT productCode,
       MAX(priceEach) AS maxPriceEach
FROM orderdetails
GROUP BY productCode
ORDER BY productCode;

-- 1.7) Recuento de compras (pagos) por país
SELECT c.country,
       COUNT(*) AS num_payments
FROM payments p
JOIN customers c ON c.customerNumber = p.customerNumber
GROUP BY c.country
ORDER BY num_payments DESC, c.country;


/* =========================
   EJERCICIO 2
   ========================= */

-- 2.1) Línea de producto con descripción más larga
SELECT productLine,
       LENGTH(textDescription) AS desc_len
FROM productlines
ORDER BY desc_len DESC
LIMIT 1;

-- 2.2) Número de clientes por oficina (según sales rep)
SELECT o.officeCode,
       o.city,
       COUNT(DISTINCT c.customerNumber) AS num_customers
FROM offices o
LEFT JOIN employees e ON e.officeCode = o.officeCode
LEFT JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY o.officeCode, o.city
ORDER BY o.officeCode;

-- 2.3) Día de la semana con más ventas de "Classic Cars"
SELECT DAYNAME(o.orderDate) AS weekday_name,
       SUM(od.quantityOrdered) AS units_sold
FROM orders o
JOIN orderdetails od ON od.orderNumber = o.orderNumber
JOIN products p ON p.productCode = od.productCode
WHERE p.productLine = 'Classic Cars'
GROUP BY DAYOFWEEK(o.orderDate), DAYNAME(o.orderDate)
ORDER BY units_sold DESC;

-- 2.4) Corregir territory faltante a "USA"
-- (a) Vista previa sin modificar datos
SELECT officeCode,
       city,
       CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 'USA'
            ELSE territory
       END AS fixed_territory
FROM offices;

-- (b) Aplicar el cambio
-- (Quita el comentario si quieres ejecutar el UPDATE)
-- UPDATE offices
-- SET territory = 'USA'
-- WHERE territory IS NULL OR TRIM(territory) = '';

-- 2.5) 2004–2005 (familia Patterson): ticket medio y total artículos por año/mes
WITH patterson_reps AS (
  SELECT employeeNumber
  FROM employees
  WHERE lastName = 'Patterson'
),
order_totals AS (
  SELECT o.orderNumber,
         YEAR(o.orderDate) AS y,
         MONTH(o.orderDate) AS m,
         SUM(od.quantityOrdered * od.priceEach) AS order_amount,
         SUM(od.quantityOrdered) AS items
  FROM orders o
  JOIN orderdetails od ON od.orderNumber = o.orderNumber
  JOIN customers c ON c.customerNumber = o.customerNumber
  WHERE c.salesRepEmployeeNumber IN (SELECT employeeNumber FROM patterson_reps)
    AND YEAR(o.orderDate) IN (2004, 2005)
  GROUP BY o.orderNumber, YEAR(o.orderDate), MONTH(o.orderDate)
)
SELECT y AS year,
       m AS month,
       AVG(order_amount) AS avg_cart_amount,
       SUM(items) AS total_items
FROM order_totals
GROUP BY y, m
ORDER BY y, m;


/* =========================
   EJERCICIO 3 (con subconsultas)
   ========================= */

-- 3.1) Mismas métricas que 2.5 pero forzando subconsultas
SELECT t.y AS year,
       t.m AS month,
       AVG(t.order_amount) AS avg_cart_amount,
       SUM(t.items) AS total_items
FROM (
  SELECT o.orderNumber,
         YEAR(o.orderDate) AS y,
         MONTH(o.orderDate) AS m,
         (SELECT SUM(od.quantityOrdered * od.priceEach)
          FROM orderdetails od
          WHERE od.orderNumber = o.orderNumber) AS order_amount,
         (SELECT SUM(od2.quantityOrdered)
          FROM orderdetails od2
          WHERE od2.orderNumber = o.orderNumber) AS items
  FROM orders o
  WHERE YEAR(o.orderDate) IN (2004, 2005)
    AND o.customerNumber IN (
      SELECT c.customerNumber
      FROM customers c
      WHERE c.salesRepEmployeeNumber IN (
        SELECT e.employeeNumber
        FROM employees e
        WHERE e.lastName = 'Patterson'
      )
    )
) AS t
GROUP BY t.y, t.m
ORDER BY t.y, t.m;

-- 3.2) Oficinas con empleados que atienden clientes sin "state"
SELECT DISTINCT o.officeCode, o.city, o.country
FROM offices o
JOIN employees e ON e.officeCode = o.officeCode
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
WHERE c.state IS NULL OR TRIM(c.state) = ''
ORDER BY o.officeCode;


