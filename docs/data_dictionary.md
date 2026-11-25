# Dawaya Pharmacy - Data Dictionary

This document provides a comprehensive overview of the database schema designed for Dawaya Pharmacy. The database has been normalized to the Third Normal Form (3NF) to eliminate data redundancy and update anomalies. 

The schema consists of 7 tables: `categories`, `products`, `branches`, `pharmacists`, `customers`, `sales`, and `sale_items`.

---

## 1. Table: `categories`
Stores the distinct categories of products sold in the pharmacy (e.g., Pain Relief, Antibiotics, Baby Care).

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `category_id` | SERIAL | PRIMARY KEY | Unique identifier for each category. |
| `category_name` | VARCHAR(100) | NOT NULL, UNIQUE | The name of the product category. |

---

## 2. Table: `products`
Stores the master list of all products available in the pharmacy. Prices are stored here to avoid update anomalies.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `product_id` | VARCHAR(20) | PRIMARY KEY | Unique alphanumeric code for the product (e.g., SKU-1001). |
| `product_name` | VARCHAR(255) | NOT NULL | The commercial name and description of the product. |
| `category_id` | INT | FOREIGN KEY (`categories`) | Links the product to its specific category. |
| `unit_price` | DECIMAL(10,2) | NOT NULL | The current standard selling price per unit. |

---

## 3. Table: `branches`
Stores information about the physical pharmacy branches.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `branch_id` | VARCHAR(10) | PRIMARY KEY | Unique identifier for the branch (e.g., BR-01). |
| `branch_name` | VARCHAR(100) | NOT NULL | The name of the branch (e.g., Dawaya Heliopolis). |
| `branch_address` | VARCHAR(255) | NOT NULL | The physical address of the branch. |

---

## 4. Table: `pharmacists`
Stores details of the pharmacists working in the pharmacy.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `pharmacist_id` | VARCHAR(10) | PRIMARY KEY | Unique identifier for the pharmacist (e.g., PH-0101). |
| `pharmacist_name` | VARCHAR(100) | NOT NULL | Full name of the pharmacist. |

---

## 5. Table: `customers`
Stores information about registered customers. Unregistered customers will have a `NULL` customer_id in the sales table.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `customer_id` | VARCHAR(20) | PRIMARY KEY | Unique identifier for the customer (e.g., CU-48235). |
| `customer_name` | VARCHAR(100) | NOT NULL | Full name of the customer. |
| `customer_phone` | VARCHAR(20) | UNIQUE | Standardized phone number (e.g., 0104345976). Nullable if not provided. |

---

## 6. Table: `sales` (Transaction Header)
Stores the header information for each transaction (receipt). It represents the "Who, When, Where, and How" of a sale.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `transaction_id` | VARCHAR(20) | PRIMARY KEY | Unique identifier for the sales transaction (e.g., TXN-7001). |
| `transaction_date` | TIMESTAMP | NOT NULL | The exact date and time the transaction occurred. |
| `branch_id` | VARCHAR(10) | FOREIGN KEY (`branches`) | The branch where the sale took place. |
| `pharmacist_id` | VARCHAR(10) | FOREIGN KEY (`pharmacists`)| The pharmacist who processed the sale. |
| `customer_id` | VARCHAR(20) | FOREIGN KEY (`customers`) | The customer who made the purchase (can be NULL for anonymous sales). |
| `payment_method` | VARCHAR(50) | NOT NULL | The method of payment (e.g., Cash, Card, InstaPay). |

---

## 7. Table: `sale_items` (Transaction Lines)
Stores the line-item details for each transaction. Because a transaction can contain multiple products, this table resolves the Many-to-Many relationship between `sales` and `products`.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `transaction_id` | VARCHAR(20) | PK, FOREIGN KEY (`sales`) | Links back to the specific transaction header. |
| `product_id` | VARCHAR(20) | PK, FOREIGN KEY (`products`) | Links to the specific product sold. |
| `quantity_sold` | INT | NOT NULL | The number of units purchased in this line item. |
| `total_line_price` | DECIMAL(10,2) | NOT NULL | The total price for this line item (Quantity * Unit Price at time of sale). |

*Note: The Primary Key of this table is a Composite Key consisting of (`transaction_id`, `product_id`).*