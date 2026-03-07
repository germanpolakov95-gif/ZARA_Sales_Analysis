# ZARA Sales Analysis
Pet project on data analysis with PostgreSQL and Tableau

## What I Did
I took Zara sales data from Kaggle, built a data warehouse in PostgreSQL, ran SQL queries for insights, and visualized it all in Tableau.

Started with a raw CSV of 252 Zara products (jackets, shoes, etc.). Modeled it into a star schema: one fact table for sales metrics and dims for products, categories, sections (Man/Woman), brands, and positions.

ETL in [project.sql](sql/project.sql): Imported data, cleaned duplicates and nulls, populated tables via joins.

Then, analytical queries in [queries.sql](sql/queries.sql): Top products, promo impact, category breakdowns (optimized with EXPLAIN ANALYZE).

**Finally, dashboard in Tableau:** https://public.tableau.com/app/profile/herman.polyakov/viz/ZARASalesAnalysis/Dashboard1

Data exports in [data/](data/) for reference.

## Some Findings
Jackets rule sales, especially for men. Aisle spots sell best. Prices around $80-100 move the most units.

## How to Run It
1. Set up PostgreSQL/pgAdmin.
2. Create DB: zara_sales_dw.
3. Run project.sql (fix CSV path).
4. Query with queries.sql.
5. Load CSVs into Tableau.

## P.S.
It shows full workflow: cleaning data, modeling, querying, viz.
