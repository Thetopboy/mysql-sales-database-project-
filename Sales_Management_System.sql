CREATE DATABASE sales_management_system;
USE sales_management_system;

SHOW TABLES;

select * from products;
select * from customers;
select * from order_details;
select * from orders;

 -- adding primary key to the tables 
ALTER TABLE customers
ADD PRIMARY KEY(customer_id);

ALTER TABLE order_details
ADD PRIMARY KEY(order_detail_id);

ALTER TABLE products
ADD PRIMARY KEY(product_id);

ALTER TABLE orders
ADD PRIMARY KEY(order_id);

 -- link orders and customers 
ALTER TABLE orders 
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

 -- linking order details to orders
ALTER TABLE order_details 
ADD CONSTRAINT fk_order_details_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- linking order details and products
ALTER TABLE order_details 
ADD CONSTRAINT fk_order_details_order_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- STEP 1 - DATA EXPLORATION QUERIES
-- 1. retreave all customers from kenya
SELECT first_name,last_name,country
FROM customers
WHERE country = 'kenya';

-- 2.list product proce above 500 usd
SELECT product_name,unit_price
FROM products
WHERE unit_price > 500;

-- 3.count total number of customers
SELECT count(*) AS total_customers
FROM customers;

-- 4. retreive all orders placed in 2024
SELECT * 
FROM orders
WHERE YEAR(order_date) = '2024'

  -- STEP 2,. RELATIONAL JOINSS AND AGGREGATION
-- show orders alongside customer details
SELECT o.order_id, c.first_name, c.last_name, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;


-- 7️⃣ Display each order with product details
SELECT od.order_id, p.product_name, od.quantity, p.unit_price
FROM order_details od
JOIN products p ON od.product_id = p.product_id;


-- 8️⃣ Calculate total orders placed by each customer
SELECT c.first_name, c.last_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;


-- 9️⃣ Compute total amount for each order
SELECT o.order_id, SUM(od.quantity * p.unit_price) AS total_amount
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY o.order_id;


-- 🔟 Calculate total spending per customer
SELECT c.first_name, c.last_name, SUM(od.quantity * p.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY c.customer_id;



/* ===========================================================
   🔹 STEP 3 — ANALYTICAL INSIGHTS & METRICS
   =========================================================== */

-- 11️⃣ Retrieve the five cheapest products
SELECT product_name, unit_price
FROM products
ORDER BY unit_price ASC
LIMIT 5;


-- 12️⃣ List Kenyan customers who have placed orders
SELECT DISTINCT c.first_name, c.last_name, c.country
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.country = 'Kenya';


-- 13️⃣ Determine the average order value
SELECT AVG(total_amount) AS avg_order_value
FROM (
    SELECT o.order_id, SUM(od.quantity * p.unit_price) AS total_amount
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY o.order_id
) AS order_totals;


-- 14️⃣ Count orders by month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;



/* ===========================================================
   🔹 STEP 4 — SUBQUERIES & BUSINESS INTELLIGENCE
   =========================================================== */

-- 15️⃣ Identify products priced above the average
SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);


-- 16️⃣ Identify customers spending above average
SELECT c.first_name, c.last_name, SUM(od.quantity * p.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY c.customer_id
HAVING total_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(od2.quantity * p2.unit_price) AS customer_total
        FROM orders o2
        JOIN order_details od2 ON o2.order_id = od2.order_id
        JOIN products p2 ON od2.product_id = p2.product_id
        GROUP BY o2.customer_id
    ) AS avg_table
);


-- 17️⃣ Identify the top-revenue product
SELECT p.product_name, SUM(od.quantity * p.unit_price) AS total_revenue
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC
LIMIT 1;


-- 18️⃣ Display the top three customers by total spending
SELECT c.first_name, c.last_name, SUM(od.quantity * p.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 3;



/* ===========================================================
   🔹 STEP 5 — VIEWS & DATA REPORTING
   =========================================================== */

-- 19️⃣ Create a view summarizing each order with total amount
CREATE VIEW order_summary AS
SELECT o.order_id, c.first_name, c.last_name, o.order_date,
       SUM(od.quantity * p.unit_price) AS total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY o.order_id;


-- 20️⃣ Use the view to show total spending by customer
SELECT first_name, last_name, SUM(total_amount) AS total_spent
FROM order_summary
GROUP BY first_name, last_name
ORDER BY total_spent DESC;
 




 
