# Interview-SQL-Mastery Portfolio: Top 20 Data Analyst Interview Queries

A curated, production-ready T-SQL portfolio project built for Microsoft SQL Server (SSMS). This repository features **20 essential, high-impact SQL queries** frequently tested in data analyst and business intelligence job interviews, backed by a fully-seeded relational practice database.

---

## Project Overview & Purpose

Designed specifically to prepare for technical data analytics interviews, this project provides a clean, self-contained environment to master core SQL concepts. Rather than dealing with overly complex enterprise clutter, it uses a streamlined schema and targeted queries to test critical data manipulation skills, including:
* Complex multi-table joins and aggregation patterns.
* Window functions, ranking, and offset analytics (`LAG`).
* Advanced problem-solving techniques like running totals, median calculations, and cohort tracking.

---

## Relational Schema Models

[Departments] ──< [Employees]
[Customers]   ──< [Orders] ──< [OrderItems] >── [Products]

* `Departments`: Organizational departments mapping internal personnel.
* `Employees`: Staff records, departmental assignments, and salary metrics.
* `Customers`: Client accounts, names, and geographical countries.
* `Products`: Catalog items, product categories, and pricing.
* `Orders`: Transaction headers, timestamps, order status, and total monetary amounts.
* `OrderItems`: Granular line-item details linking orders to specific products.

---

## Technical Scope & Competencies Demonstrated

### 1. Core Aggregations & Filtering
* Grouping data and summarizing metrics (`SUM`, `COUNT`) by categories.
* Filtering aggregate outcomes using `HAVING` versus row-level filtering using `WHERE`.
* Multi-table transactional joins and pattern matching.

### 2. Advanced Analytics & Window Functions
* **Ranking & Partitioning:** Using `ROW_NUMBER`, `RANK`, and `DENSE_RANK` to evaluate data hierarchies.
* **Time-Series & Financials:** Tracking Month-over-Month (MoM) growth using `LAG`, computing cumulative running totals, and calculating moving averages with custom window frames (`ROWS BETWEEN`).
* **Statistical Distribution:** Finding median salary values using `PERCENTILE_CONT` and bucket segmentation using `NTILE`.

### 3. Problem-Solving Patterns
* **Anti-Joins:** Finding unmatched records (e.g., customers with zero orders).
* **Conditional Aggregation:** Generating pivot-style summaries using `CASE` statements.
* **Cohort Identification:** Extracting first-order dates to track initial customer activity.

---

## Getting Started

1. Open **SQL Server Management Studio (SSMS)**.
2. Run the complete script to automatically create the `InterviewMastery` database, seed the tables, and review the query library.
3. Use the descriptive comments above each query block to test your own code before checking the provided solutions.
