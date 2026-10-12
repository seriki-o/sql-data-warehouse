# SQL Server Data Warehouse

A data warehouse built with Microsoft SQL Server and T-SQL to integrate CRM and ERP data into a structured, analytics-ready model using the Medallion Architecture.

## Project Overview

This project demonstrates the development of a data warehouse that consolidates sales-related data from multiple source systems into a centralised environment. It implements a layered data pipeline for raw data ingestion, data cleansing, standardisation, and analytical modelling.

The final Gold layer presents integrated customer, product, and sales data through a star schema designed to support analytical queries and reporting.

## Architecture

The warehouse follows the Medallion Architecture, with three layers:

- **Bronze:** Ingests raw CRM and ERP data from CSV files into SQL Server.
- **Silver:** Cleans, standardises, and transforms data to improve consistency and quality.
- **Gold:** Integrates the transformed data into customer and product dimensions and a sales fact view.

![SQL Server Data Warehouse Architecture](./docs/high-level-architecture.png)

## Technologies

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Stored Procedures and Views
- Bulk Data Loading
- Data Cleansing and Transformation
- Dimensional Modelling and Star Schema
- Data Quality Testing

## Key Features

- Integrated data from six CRM and ERP source tables.
- Implemented stored procedures to orchestrate Bronze and Silver layer loading.
- Applied data cleansing, standardisation, deduplication, and derived-column transformations.
- Designed Gold-layer customer and product dimensions alongside a sales fact view.
- Implemented data quality checks to assess data consistency and dimensional relationships.
- Documented the warehouse architecture, data flow, integration model, and dimensional schema.

## Repository Structure

| Directory | Description |
|---|---|
| `dataset/` | Source CSV files |
| `docs/` | Architecture diagrams, data flow models, integration diagrams, and data catalog |
| `scripts/` | Database initialisation, table creation, loading procedures, transformations, and Gold views |
| `tests/` | Silver and Gold data quality checks |

## Data Model

The Gold layer uses a star schema consisting of:

- **`gold.fact_sales`** — sales transactions, dates, quantities, prices, and sales amounts.
- **`gold.dim_customers`** — customer details, location, demographic attributes, and creation date.
- **`gold.dim_products`** — product details, categories, costs, and product-line information.

This structure supports analysis across customers, products, and sales transactions.

## Documentation

- [Technical Documentation](./docs/technical_documentation.md)
- [High-Level Architecture and Data Flow Diagrams](./docs/)
- [SQL Scripts](./scripts/)
- [Data Quality Tests](./tests/)

## Getting Started

1. Clone this repository.
2. Open SQL Server Management Studio and connect to your SQL Server instance.
3. Review and execute the database initialisation script in `scripts/`.
4. Configure the source file paths in the Bronze loading scripts for your local environment.
5. Run the Bronze and Silver loading procedures in sequence.
6. Create or update the Gold views and execute the data quality checks.

Refer to the [technical documentation](./docs/technical_documentation.md) for implementation details and execution guidance.

## Author

**O. Seriki**

<p align="left">
  <a href="https://github.com/seriki-o">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
  </a>
  <a href="[YOUR-LINKEDIN-URL](https://www.linkedin.com/in/oreoluwa-seriki-51a30424a)">
    <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>
