-- =====================================================================
-- Dawaya Pharmacy - queries.sql  
-- Revenue everywhere = SUM(quantity * unit_price) from sale_items.
-- Run after schema.sql and seed.sql.

--  FILTERING AND SORTING
-- =====================================================================

-- Q1. Products with current unit price above EGP 300, most expensive first
SELECT p.sku,
       p.product_name,
       c.category_name,
       p.current_price
FROM products p
INNER JOIN categories c ON c.category_id = p.category_id
WHERE p.current_price > 300
ORDER BY p.current_price DESC, p.product_name;


-- Q2. Transactions at Dawaya Heliopolis in August 2026, newest first
SELECT s.transaction_code,
       s.sale_date,
       ph.pharmacist_name,
       s.payment_method
FROM sales s
INNER JOIN branches b      ON b.branch_id      = s.branch_id
INNER JOIN pharmacists ph  ON ph.pharmacist_id = s.pharmacist_id
WHERE b.branch_name = 'Dawaya Heliopolis'
  AND s.sale_date >= '2026-08-01'
  AND s.sale_date <  '2026-09-01'
ORDER BY s.sale_date DESC;


-- Q3. Guest checkouts paid in cash at Nasr City or Dokki, by date
SELECT s.transaction_code,
       s.sale_date,
       b.branch_name,
       s.payment_method
FROM sales s
INNER JOIN branches b ON b.branch_id = s.branch_id
WHERE s.customer_id IS NULL
  AND s.payment_method = 'Cash'
  AND (b.branch_name = 'Dawaya Nasr City' OR b.branch_name = 'Dawaya Dokki')
ORDER BY s.sale_date;



-- PART 2: AGGREGATION
-- =====================================================================

-- Q4. Revenue and number of transactions per branch (more than 35 transactions)
SELECT b.branch_name,
       SUM(si.quantity * si.unit_price) AS total_revenue,
       COUNT(DISTINCT s.sale_id)        AS transactions
FROM branches b
INNER JOIN sales s       ON s.branch_id = b.branch_id
INNER JOIN sale_items si ON si.sale_id  = s.sale_id
GROUP BY b.branch_id, b.branch_name
HAVING COUNT(DISTINCT s.sale_id) > 35
ORDER BY total_revenue DESC;


-- Q5. Units sold and average unit price per category (more than 90 units)
SELECT c.category_name,
       SUM(si.quantity)           AS total_quantity,
       ROUND(AVG(si.unit_price), 2) AS avg_unit_price
FROM categories c
INNER JOIN products p    ON p.category_id = c.category_id
INNER JOIN sale_items si ON si.product_id = p.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(si.quantity) > 90
ORDER BY total_quantity DESC;


-- Q6. Revenue handled and average transaction value per pharmacist (above EGP 15,000)
SELECT ph.pharmacist_name,
       SUM(si.quantity * si.unit_price)                          AS total_revenue,
       ROUND(SUM(si.quantity * si.unit_price)
             / COUNT(DISTINCT s.sale_id), 2)                     AS avg_transaction_value
FROM pharmacists ph
INNER JOIN sales s       ON s.pharmacist_id = ph.pharmacist_id
INNER JOIN sale_items si ON si.sale_id      = s.sale_id
GROUP BY ph.pharmacist_id, ph.pharmacist_name
HAVING SUM(si.quantity * si.unit_price) > 15000
ORDER BY total_revenue DESC;



-- PART 3: JOINS ACROSS THREE OR MORE TABLES
-- =====================================================================

-- Q7. Top 10 loyalty customers by total spend
SELECT cu.customer_name,
       cu.customer_phone,
       COUNT(DISTINCT s.sale_id)        AS visits,
       SUM(si.quantity * si.unit_price) AS total_spent
FROM customers cu
INNER JOIN sales s       ON s.customer_id = cu.customer_id
INNER JOIN sale_items si ON si.sale_id    = s.sale_id
GROUP BY cu.customer_id, cu.customer_name, cu.customer_phone
ORDER BY total_spent DESC, cu.customer_name
LIMIT 10;


-- Q8. Itemized receipt for transaction TXN-7009
--     (LEFT JOIN on customers so a guest checkout would still print)
SELECT s.transaction_code,
       s.sale_date,
       b.branch_name,
       ph.pharmacist_name,
       COALESCE(cu.customer_name, 'Guest') AS customer,
       p.product_name,
       si.quantity,
       si.unit_price,
       si.quantity * si.unit_price         AS line_total
FROM sales s
INNER JOIN branches b      ON b.branch_id      = s.branch_id
INNER JOIN pharmacists ph  ON ph.pharmacist_id = s.pharmacist_id
LEFT  JOIN customers cu    ON cu.customer_id   = s.customer_id
INNER JOIN sale_items si   ON si.sale_id       = s.sale_id
INNER JOIN products p      ON p.product_id     = si.product_id
WHERE s.transaction_code = 'TXN-7009'
ORDER BY p.product_name;


-- Q9. Dawaya Smouha: every product sold, with category and total quantity
SELECT c.category_name,
       p.product_name,
       SUM(si.quantity) AS total_quantity
FROM branches b
INNER JOIN sales s       ON s.branch_id   = b.branch_id
INNER JOIN sale_items si ON si.sale_id    = s.sale_id
INNER JOIN products p    ON p.product_id  = si.product_id
INNER JOIN categories c  ON c.category_id = p.category_id
WHERE b.branch_name = 'Dawaya Smouha'
GROUP BY c.category_name, p.product_id, p.product_name
ORDER BY c.category_name, total_quantity DESC, p.product_name;


-- Q10. Every branch with each pharmacist and the revenue handled
--      (LEFT JOINs keep branches/pharmacists that have no sales, with 0 revenue)
SELECT b.branch_name,
       ph.pharmacist_name,
       COALESCE(SUM(si.quantity * si.unit_price), 0) AS total_revenue
FROM branches b
LEFT JOIN pharmacists ph ON ph.branch_id     = b.branch_id
LEFT JOIN sales s        ON s.pharmacist_id  = ph.pharmacist_id
LEFT JOIN sale_items si  ON si.sale_id       = s.sale_id
GROUP BY b.branch_id, b.branch_name, ph.pharmacist_id, ph.pharmacist_name
ORDER BY b.branch_name, total_revenue DESC;