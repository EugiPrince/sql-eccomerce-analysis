-- E-commerce SQL Analysis Project

-- 1. Total Revenue
SELECT SUM(payment_value) AS total_revenues
FROM order_payments op ;

-- 2. Average Order Value
SELECT 
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM order_payments;

-- 3. Total Revenue per Product
SELECT oi.product_id, ROUND(SUM(op.payment_value), 2) AS revenue_product
FROM order_items oi
JOIN order_payments op ON oi.order_id = op.order_id
GROUP BY oi.product_id
ORDER BY revenue_product DESC
LIMIT 10;

-- 4. Revennue Trend per Month
SELECT 
    DATE_FORMAT(o.order_purchase_ts, '%Y-%m') AS month,
    ROUND(SUM(payment_value), 2) AS revenue
FROM orders o, order_payments op
WHERE o.order_id = op.order_id
GROUP BY month
ORDER BY month;

-- 5. Estimated Revenue Per Product
SELECT 
    oi.product_id,
    ROUND(SUM(op.payment_value / t.item_count), 2) AS estimated_revenue
FROM order_items oi, order_payments op,
     (SELECT order_id, COUNT(*) AS item_count
      FROM order_items
      GROUP BY order_id) t
WHERE oi.order_id = op.order_id AND oi.order_id = t.order_id
GROUP BY oi.product_id
ORDER BY estimated_revenue DESC
LIMIT 10;

-- 6. Top Ten Spending Customers
SELECT c.customer_id, ROUND(SUM(op.payment_value), 2) AS total_spent
FROM customers c, orders o, order_payments op
WHERE o.order_id = op.order_id AND o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 7. Customer Segmentation
SELECT o.customer_id, SUM(op.payment_value) AS total_spent,
	   CASE
	   	WHEN SUM(op.payment_value) > 1000 THEN 'High Value'
	   	WHEN SUM(op.payment_value) > 500 THEN 'Medium Value'
	   	ELSE 'Low Value'
	   END AS customer_segment
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY o.customer_id;

-- 8. Customer Segmentation Analysis: how many customers in each segment
-- and the average spending in each segment
SELECT 
    customer_segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(total_spent), 2) AS avg_spent
FROM (
    SELECT 
        o.customer_id,
        SUM(op.payment_value) AS total_spent,
        CASE 
            WHEN SUM(op.payment_value) > 1000 THEN 'High Value'
            WHEN SUM(op.payment_value) > 500 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    GROUP BY o.customer_id
) t
GROUP BY customer_segment
ORDER BY avg_spent DESC;