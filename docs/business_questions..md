# Dawaya Pharmacy - Business Questions (answered)

**From:** Tarek El-Sayed, VP of Operations
**Data:** normalized PostgreSQL database loaded from `flat_sales_export.csv` (1 July - 30 September 2026). All amounts are in Egyptian pounds (EGP).
Revenue = `SUM(quantity * unit_price)`, using the unit price at the time of sale after data cleaning. The export is a random sample, so absolute figures describe the sample, not the whole chain.

---

## Part 1: Filtering and sorting

### Question 1
List every product whose current unit price is above EGP 300, with its category, sorted from the most expensive.

```sql
SELECT p.sku, p.product_name, c.category_name, p.current_price
FROM products p
INNER JOIN categories c ON c.category_id = p.category_id
WHERE p.current_price > 300
ORDER BY p.current_price DESC, p.product_name;
```

**Result:** 10 products, from La Roche-Posay Anthelios SPF50 (1,120) down to Lipitor 20mg (336).

**Business insight:** Ten of the 32 products are priced above EGP 300, and three of them are Skin Care. Because Lantus (990) and the other premium lines are also the items that went up on 15 August, stock availability and price accuracy matter most for this group.


### Question 2
List all transactions at Dawaya Heliopolis in August 2026 with their date, pharmacist and payment method, newest first.

```sql
SELECT s.transaction_code, s.sale_date, ph.pharmacist_name, s.payment_method
FROM sales s
INNER JOIN branches b     ON b.branch_id      = s.branch_id
INNER JOIN pharmacists ph ON ph.pharmacist_id = s.pharmacist_id
WHERE b.branch_name = 'Dawaya Heliopolis'
  AND s.sale_date >= '2026-08-01'
  AND s.sale_date <  '2026-09-01'
ORDER BY s.sale_date DESC;
```

**Result:** 21 transactions, from TXN-7362 (31 Aug) back to TXN-7205 (4 Aug).

**Business insight:** Heliopolis recorded 21 transactions in August, and 13 of them (about 62%) were paid in cash against 5 by card and 3 by InstaPay. The branch still depends heavily on cash handling.


### Question 3
List the guest checkouts (no loyalty customer) that were paid in cash at Dawaya Nasr City or Dawaya Dokki, sorted by date.

```sql
SELECT s.transaction_code, s.sale_date, b.branch_name, s.payment_method
FROM sales s
INNER JOIN branches b ON b.branch_id = s.branch_id
WHERE s.customer_id IS NULL
  AND s.payment_method = 'Cash'
  AND (b.branch_name = 'Dawaya Nasr City' OR b.branch_name = 'Dawaya Dokki')
ORDER BY s.sale_date;
```

**Result:** 11 transactions: 8 at Nasr City and 3 at Dokki.

**Business insight:** These 11 sales are anonymous and paid in cash, so they leave no customer record and no card trail. They are the best target for a loyalty sign-up prompt at the till.

---

## Part 2: Aggregation

### Question 4
For each branch, show the total revenue and the number of transactions. Show only branches with more than 35 transactions, highest revenue first.

```sql
SELECT b.branch_name,
       SUM(si.quantity * si.unit_price) AS total_revenue,
       COUNT(DISTINCT s.sale_id)        AS transactions
FROM branches b
INNER JOIN sales s       ON s.branch_id = b.branch_id
INNER JOIN sale_items si ON si.sale_id  = s.sale_id
GROUP BY b.branch_id, b.branch_name
HAVING COUNT(DISTINCT s.sale_id) > 35
ORDER BY total_revenue DESC;
```

**Result:** Nasr City 57,077 (72 transactions), Heliopolis 50,506 (63), Maadi 35,476 (49), Mansoura 30,500 (38).

**Business insight:** Nasr City and Heliopolis together bring in about 49% of all sampled revenue. Dokki and Smouha fall below the 35-transaction cut-off, so they are the branches to look at for growth.


### Question 5
For each product category, show the total quantity sold and the average unit price. Show only categories with more than 90 units sold.

```sql
SELECT c.category_name,
       SUM(si.quantity)             AS total_quantity,
       ROUND(AVG(si.unit_price), 2) AS avg_unit_price
FROM categories c
INNER JOIN products p    ON p.category_id = c.category_id
INNER JOIN sale_items si ON si.product_id = p.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(si.quantity) > 90
ORDER BY total_quantity DESC;
```

**Result:** 6 categories pass: Cold & Flu 137 units (avg 55.41), Baby Care 124 (369.96), Vitamins & Supplements 114 (361.13), Pain Relief 102 (63.14), Diabetes 96 (440.65), Cardiovascular 91 (155.83).

**Business insight:** Cold & Flu moves the most units at a low price, while Baby Care, Vitamins and Diabetes sell fewer units at EGP 360-440 each, so they carry much more revenue per unit. Skin Care, Digestive Health and Antibiotics did not reach 90 units.

*Note: the average is taken over the sold lines using the price at the time of sale.*


### Question 6
For each pharmacist, show the total revenue they handled and their average transaction value. Show only pharmacists above EGP 15,000.

```sql
SELECT ph.pharmacist_name,
       SUM(si.quantity * si.unit_price) AS total_revenue,
       ROUND(SUM(si.quantity * si.unit_price)
             / COUNT(DISTINCT s.sale_id), 2) AS avg_transaction_value
FROM pharmacists ph
INNER JOIN sales s       ON s.pharmacist_id = ph.pharmacist_id
INNER JOIN sale_items si ON si.sale_id      = s.sale_id
GROUP BY ph.pharmacist_id, ph.pharmacist_name
HAVING SUM(si.quantity * si.unit_price) > 15000
ORDER BY total_revenue DESC;
```

**Result:** 6 pharmacists: Amina Mansour 31,969 (avg 743.47), Mostafa Ramadan 29,635 (800.95), Heba Lotfy 27,442 (784.06), Karim Fathy 22,247 (967.26), Salma Abdelrahman 20,551 (733.96), Mohamed Saber 18,537 (926.85).

**Business insight:** Amina Mansour handles the most revenue, but Karim Fathy has the highest average basket (EGP 967) and Mohamed Saber is next (EGP 927). Those two are the ones to learn from on upselling and bundling.

---

## Part 3: Joins across three or more tables

### Question 7
Who are the top 10 loyalty customers by total spend? Show name, phone, number of visits and total spent.

```sql
SELECT cu.customer_name, cu.customer_phone,
       COUNT(DISTINCT s.sale_id)        AS visits,
       SUM(si.quantity * si.unit_price) AS total_spent
FROM customers cu
INNER JOIN sales s       ON s.customer_id = cu.customer_id
INNER JOIN sale_items si ON si.sale_id    = s.sale_id
GROUP BY cu.customer_id, cu.customer_name, cu.customer_phone
ORDER BY total_spent DESC, cu.customer_name
LIMIT 10;
```

**Result:** Top customer is Tarek Lotfy (EGP 5,627 over 6 visits), followed by Mostafa Shalaby and Rania Soliman (both 5,464).

**Business insight:** The top 10 customers out of 95 account for about EGP 48,800, roughly 22% of total sampled revenue. Rania Soliman spent the same as Mostafa Shalaby in only 2 visits instead of 5, so she is a high-value customer worth a personal follow-up.


### Question 8
Print an itemized receipt for transaction `TXN-7009`: date, branch, pharmacist, customer, each product with quantity, unit price and line total.

```sql
SELECT s.transaction_code, s.sale_date, b.branch_name, ph.pharmacist_name,
       COALESCE(cu.customer_name, 'Guest') AS customer,
       p.product_name, si.quantity, si.unit_price,
       si.quantity * si.unit_price AS line_total
FROM sales s
INNER JOIN branches b     ON b.branch_id      = s.branch_id
INNER JOIN pharmacists ph ON ph.pharmacist_id = s.pharmacist_id
LEFT  JOIN customers cu   ON cu.customer_id   = s.customer_id
INNER JOIN sale_items si  ON si.sale_id       = s.sale_id
INNER JOIN products p     ON p.product_id     = si.product_id
WHERE s.transaction_code = 'TXN-7009'
ORDER BY p.product_name;
```

**Result:** 2 July 2026 15:01, Dawaya Smouha, pharmacist Dina El-Gamal, customer Aya Farouk: Comtrex x2 = 104, Feroglobin x1 = 236, La Roche-Posay Anthelios SPF50 x1 = 1,120, Otrivin x4 = 164. Receipt total EGP 1,624.

**Business insight:** One sunscreen is 69% of this EGP 1,624 receipt. Every line total is now calculated from quantity and price, so a receipt can no longer show a hand-typed total that disagrees with its items.


### Question 9
For Dawaya Smouha, list every product sold with its category and total quantity, sorted by category and then by quantity (highest first).

```sql
SELECT c.category_name, p.product_name, SUM(si.quantity) AS total_quantity
FROM branches b
INNER JOIN sales s       ON s.branch_id   = b.branch_id
INNER JOIN sale_items si ON si.sale_id    = s.sale_id
INNER JOIN products p    ON p.product_id  = si.product_id
INNER JOIN categories c  ON c.category_id = p.category_id
WHERE b.branch_name = 'Dawaya Smouha'
GROUP BY c.category_name, p.product_id, p.product_name
ORDER BY c.category_name, total_quantity DESC, p.product_name;
```

**Result:** 26 of the 32 products were sold at Smouha. Top sellers: Otrivin Nasal Spray 8, Nexium 7, Concor 6, Comtrex 6.

**Business insight:** Smouha's demand is led by cold and digestive products. Pain Relief appears only through Brufen (4 units), with no Panadol or Cataflam sales in the sample, so that category looks under-stocked or under-recommended here.


### Question 10
List every branch with each of its pharmacists and the revenue each pharmacist handled. Branches and pharmacists with no sales must still appear, with 0 revenue.

```sql
SELECT b.branch_name, ph.pharmacist_name,
       COALESCE(SUM(si.quantity * si.unit_price), 0) AS total_revenue
FROM branches b
LEFT JOIN pharmacists ph ON ph.branch_id    = b.branch_id
LEFT JOIN sales s        ON s.pharmacist_id = ph.pharmacist_id
LEFT JOIN sale_items si  ON si.sale_id      = s.sale_id
GROUP BY b.branch_id, b.branch_name, ph.pharmacist_id, ph.pharmacist_name
ORDER BY b.branch_name, total_revenue DESC;
```

**Result:** 13 rows covering all 7 branches and 13 pharmacists. Dawaya New Capital (Mai Hossam) shows 0.

**Business insight:** In every branch one pharmacist handles more than the other, most clearly at Heliopolis where Amina Mansour handles about 63% of the branch revenue. Dawaya New Capital opened on 1 October, after this period, so its 0 is expected and the LEFT JOINs keep it visible for future tracking.
