# SQL Server Data Warehouse — Technical Documentation

## 1. Project Overview

This project implements a SQL Server data warehouse that consolidates sales data from Customer Relationship Management (CRM) and Enterprise Resource Planning (ERP) source files into a structured, analytics-ready model.

The solution follows the Medallion Architecture, separating raw data ingestion, data cleansing and standardisation, and business-ready data integration. The final Gold layer uses a star schema to support reporting and analytical queries.

**Technologies:** Microsoft SQL Server, SQL, SQL Server Management Studio (SSMS), CSV, and draw.io.

## 2. Project Requirements

The project aims to:

- Consolidate CRM and ERP data into a central data warehouse.
- Preserve source data in a raw layer.
- Improve data quality through cleansing and standardisation.
- Integrate related customer, product, and sales information.
- Provide a dimensional model suitable for analytical queries and reporting.
- Validate data quality and relationships across the warehouse.

## 3. Architecture and Design

The warehouse uses three layers:

| Layer | Purpose | Implementation |
|---|---|---|
| Bronze | Store source data with minimal modification. | SQL Server tables populated from CSV files. |
| Silver | Clean, standardise, and transform source data. | SQL Server tables populated through transformation scripts. |
| Gold | Present integrated, business-ready data. | SQL views organised as a star schema. |

CRM and ERP CSV files serve as the source data. Data flows through the Bronze and Silver layers before being integrated into the Gold layer.

### Architecture Diagram

<img width="818" height="476" alt="Screenshot 2026-10-09 171523" src="https://github.com/user-attachments/assets/7fad98ba-b544-4e5b-9a61-0b9ff9f40416" />


## 4. Project Initialisation

The project was organised into separate directories for source datasets, documentation, SQL scripts, and data quality checks.

A SQL Server database named `DataWarehouse` was created, alongside the `bronze`, `silver`, and `gold` schemas.

The repository structure is organised as follows:

- `dataset/` — source CSV files.
- `docs/` — architecture diagrams, data flow diagrams, integration models, and data catalog.
- `scripts/` — database initialisation, table definitions, transformation scripts, and stored procedures.
- `tests/` — Silver and Gold data quality checks.
- `README.md` — project summary and navigation.
- `LICENSE` — project licensing information.

## 5. Source Data Analysis

The source data consists of six CRM and ERP tables.

**CRM sources**

- `crm_cust_info` — customer information.
- `crm_prd_info` — product information, including product history.
- `crm_sales_details` — sales transactions.

**ERP sources**

- `erp_cust_az12` — supplementary customer information, including birthdates and gender.
- `erp_loc_a101` — customer location and country information.
- `erp_px_cat_g1v2` — product categories, subcategories, and maintenance information.

The source tables were examined to understand their structures, identifiers, relationships, data types, and quality issues before transformations were implemented.

### Integration Model

The integration model documents the relationships between source entities and identifies how CRM and ERP records can be combined. Customer records are enriched with ERP customer and location information, while product records are enriched with ERP category information.
<img width="866" height="461" alt="Screenshot 2026-10-11 165559" src="https://github.com/user-attachments/assets/1074a0ec-0de4-4944-b1a7-024732eda5c1" />

## 6. Bronze Layer — Raw Data Ingestion

The Bronze layer provides the initial landing area for the source data.

### Implementation

- Created six tables corresponding to the CRM and ERP source files.
- Used `BULK INSERT` to load CSV data into SQL Server.
- Implemented full-refresh loading by truncating existing data and inserting the source data again.
- Created the stored procedure `bronze.load_bronze` to coordinate the ingestion process.
- Added progress messages, execution-time measurements, and `TRY...CATCH` error handling.
- Compared loaded row counts with source data to validate ingestion.

No intentional business transformations are performed in this layer. The objective is to retain the source data in a form suitable for subsequent processing.

Relevant scripts: [View Bronze Scripts](../scripts/bronze/) and [Database Initialisation Script](../scripts/init_database.sql).

### Data Flow

<img width="705" height="436" alt="Screenshot 2026-10-12 144859" src="https://github.com/user-attachments/assets/1df09019-23a6-4943-a7fd-c5e72584f7aa" />

## 7. Silver Layer — Data Cleansing and Transformation

The Silver layer improves the consistency and usability of the raw data. Transformation scripts create and populate the corresponding Silver tables, while `silver.load_silver` coordinates the loading process.

The layer uses full-refresh loading and applies the following transformations.

### Customer Information

For `silver.crm_cust_info`:

- Removed duplicate customer records by retaining the latest record according to `cst_create_date`.
- Excluded records with null customer identifiers.
- Removed unwanted whitespace from customer names.
- Standardised marital status and gender codes into readable values.
- Used `n/a` for unrecognised or unavailable categorical values.

### Product Information

For `silver.crm_prd_info`:

- Derived category identifiers from product keys.
- Standardised product keys for integration with other source tables.
- Replaced null product costs with zero.
- Mapped product-line codes to descriptive labels.
- Converted product start dates to the `DATE` data type.
- Derived product end dates from the next start date within each product's history, subtracting one day.

### Sales Details

For `silver.crm_sales_details`:

- Converted valid eight-digit date values into SQL `DATE` values.
- Replaced invalid or missing date representations with `NULL`.
- Recalculated inconsistent or invalid sales amounts using quantity and price.
- Derived missing or invalid prices from sales and quantity where possible, protecting against division by zero.
- Applied consistency checks to sales amounts, quantities, prices, and dates.

### ERP Customer Information

For `silver.erp_cust_az12`:

- Removed the `NAS` prefix from customer identifiers where present.
- Replaced future birthdates with `NULL`.
- Standardised gender values and handled unavailable or unrecognised values.

### ERP Location Information

For `silver.erp_loc_a101`:

- Removed hyphens from customer identifiers to support integration.
- Standardised country codes and names, including Germany and the United States.
- Replaced null or blank country values with `n/a`.

### ERP Product Categories

For `silver.erp_px_cat_g1v2`:

- Loaded product category, subcategory, and maintenance information into the Silver layer.
- Prepared the data for integration with CRM product records.
- Included data quality checks for whitespace and distinct values.

The Silver tables also include a `dwh_create_date` technical column to record when a row is created in the warehouse.

Relevant scripts: [View Silver Scripts](./scripts/silver/).

## 8. Gold Layer — Analytical Data Model

The Gold layer exposes three SQL views that combine cleaned data into a dimensional model.

### `gold.dim_customers`

The customer dimension combines CRM customer records with ERP customer and location information.

It includes customer identifiers, names, country, marital status, gender, birthdate, and creation date. Gender uses the CRM value when available and otherwise falls back to the ERP value.

### `gold.dim_products`

The product dimension combines CRM product information with ERP category data. It includes product identifiers, names, categories, subcategories, maintenance requirements, cost, product line, and start date.

The view filters for products whose `prd_end_dt` is `NULL`, representing the current product records according to the implemented date logic.

### `gold.fact_sales`

The sales fact view combines sales transaction data with the customer and product dimensions. It contains order number, customer and product keys, order, shipping and due dates, sales amount, quantity, and price.

The intended grain is **one row per sales order line item**.

The customer and product dimensions are connected to the fact view using `customer_key` and `product_key`, respectively. Left joins preserve sales records even when a matching dimension record cannot be found.

### Star Schema

<img width="772" height="500" alt="Screenshot 2026-10-11 190209" src="https://github.com/user-attachments/assets/2bd9ee77-eccc-48da-afb8-d39ef937c0f7" />

The model separates descriptive customer and product attributes from transactional sales measures, making it easier to analyse sales by customer, product, category, and date.

Relevant scripts: [View Gold Scripts](./scripts/gold/). The Gold views are defined using `CREATE OR ALTER VIEW`; they are virtual tables rather than physically materialised tables.

## 9. Data Quality and Validation

Data quality checks were organised into Silver and Gold validation scripts.

**Silver-layer checks include:**

- Null and duplicate identifiers.
- Unwanted whitespace and inconsistent categorical values.
- Invalid product costs and date ranges.
- Sales, price, and quantity consistency.
- Invalid birthdates and inconsistent source values.

**Gold-layer checks include:**

- Duplicate customer or product records.
- Unexpected dimension values.
- Missing customer or product matches from sales records.
- Referential integrity between the fact and dimension views.

These checks help identify problems introduced by source data quality issues or transformation logic before the data is used for analysis.

Relevant scripts: [Data Quality Tests](../tests/)
.

## 10. Execution Workflow

The intended workflow is:

1. Initialise the database and create the required schemas and tables.
2. Execute `bronze.load_bronze` to ingest the source files.
3. Execute `silver.load_silver` to clean and standardise the data.
4. Create or update the Gold views using the scripts in the Gold directory.
5. Run the Silver and Gold data quality checks.
6. Query the Gold views for analytical reporting.

The Gold views reference the Silver tables and generate their results when queried. They do not require a separate Gold data-loading procedure.

## 11. Limitations and Considerations

- **Full-refresh loading:** Bronze and Silver are reloaded rather than incrementally updated. This is suitable for a learning project but may become inefficient as data volumes grow.
- **Surrogate key stability:** The dimension keys use `ROW_NUMBER()`. These keys can change when the underlying data or ordering changes, so persistent surrogate keys would be preferable for a production warehouse.
- **Historical product records:** The current product dimension excludes records with a populated end date. Historical product analysis would require a different modelling approach.
- **Unmatched records:** Left joins preserve sales rows even when dimension keys are unavailable. These cases should be monitored through validation checks.
- **Production readiness:** Additional work would be required for incremental loading, transaction recovery, orchestration, monitoring, security, and production deployment.

## 12. Skills Demonstrated

This project demonstrates practical experience with SQL Server database setup, T-SQL, bulk data ingestion, stored procedures, data cleansing, data standardisation, ETL workflows, relational joins, dimensional modelling, star schema design, and data quality validation.

## 13. Acknowledgements

This project was developed as a hands-on learning exercise, using [Data with Baraa's SQL Data Warehouse tutorial](https://www.youtube.com/watch?v=9GVqKuTVANE) as a learning reference. This documentation describes the implementation, SQL scripts, transformations, validation checks, and project structure maintained in this repository.
