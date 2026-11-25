# Dawaya — Database Architecture & Sales Insights

## Overview
**Dawaya** is a relational database and business analytics project focused on pharmacy/pharmaceutical sales operations. The project transforms flat raw sales export data into a structured relational schema, populates sample/seed data, answers key business questions through SQL queries, and documents the data model and analytical insights.

---

## Project Structure

```text
dawaya_project_deliverables/
├── scripts/
│   ├── schema.sql          # Relational database tables, primary/foreign keys, and constraints
│   ├── seed.sql            # Sample / seed records for populating the database
│   └── queries.sql         # Analytical and reporting SQL queries for business questions
├── docs/
│   ├── Dawaya_Database_Architecture_and_Insights.pdf   # Architecture overview & key insights report
│   ├── data_dictionary.md  # Detailed description of entities, columns, data types, and relationships
│   └── business_questions.md # Core business questions driving the SQL analysis
├── data/
│   └── flat_sales_export.csv # Raw flat sales export dataset
└── README.md               # Project documentation and execution guide
```

---

## How to Run the SQL Scripts

Execute the scripts in the following order on your target SQL database (PostgreSQL / MySQL / SQLite — adjust syntax if needed based on your SQL dialect):

1. **Create the Schema (`scripts/schema.sql`)**
   Creates all required tables, constraints, and relationships.
   ```sql
   -- Run scripts/schema.sql first
   ```

2. **Load Seed Data (`scripts/seed.sql`)**
   Inserts initial reference and sample data into the created tables.
   ```sql
   -- Run scripts/seed.sql second
   ```

3. **Run Analytical Queries (`scripts/queries.sql`)**
   Executes queries designed to answer the business questions documented in `docs/business_questions.md`.
   ```sql
   -- Run scripts/queries.sql third
   ```

---

## Documentation & Data

- **`data/flat_sales_export.csv`**: Source flat export containing raw sales records prior to normalization/modeling.
- **`docs/data_dictionary.md`**: Reference guide for tables, fields, keys, and business rules.
- **`docs/business_questions.md`**: List of core operational and sales questions addressed by the project.
- **`docs/Dawaya_Database_Architecture_and_Insights.pdf`**: Summary of database design decisions, data flow, and key business takeaways.

---

## Pre-Submission Checklist
- [ ] Verify that `scripts/schema.sql`, `scripts/seed.sql`, and `scripts/queries.sql` each contain their respective SQL code (no swapped contents or duplicate names).
- [ ] Verify clean filenames inside `docs/` (e.g., `business_questions.md`) and `data/` (`flat_sales_export.csv`).
- [ ] Confirm `README.md` is placed at the root of `dawaya_project_deliverables/`.
- [ ] Test running `schema.sql` followed by `seed.sql` and `queries.sql` without errors.