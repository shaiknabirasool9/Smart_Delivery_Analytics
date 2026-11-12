USE food_delivery_db;

-- Record Counts

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM restaurants;
SELECT COUNT(*) FROM delivery_partners;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM ratings;
SELECT COUNT(*) FROM customer_behavior;

-- Null Checks

SELECT *
FROM customers
WHERE customer_id IS NULL
OR customer_name IS NULL;

SELECT *
FROM restaurants
WHERE restaurant_id IS NULL
OR restaurant_name IS NULL;

SELECT *
FROM orders
WHERE order_id IS NULL;

-- Duplicate Checks

SELECT customer_id,COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT restaurant_id,COUNT(*)
FROM restaurants
GROUP BY restaurant_id
HAVING COUNT(*) > 1;

SELECT order_id,COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Foreign Key Validation

SELECT COUNT(*)
FROM orders o
LEFT JOIN customers c
ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*)
FROM orders o
LEFT JOIN restaurants r
ON o.restaurant_id=r.restaurant_id
WHERE r.restaurant_id IS NULL;

SELECT COUNT(*)
FROM orders o
LEFT JOIN delivery_partners d
ON o.partner_id=d.partner_id
WHERE d.partner_id IS NULL;