# Data Dictionary for Gold layer

## Overview

The Gold Layer contains business-ready data organised into **dimension tables** and **fact tables** to support reporting, business intelligence, and analytical queries.

Dimension tables provide descriptive context about business entities, while fact tables store measurable business events and metrics. Together, they form a dimensional model designed to simplify data analysis and reporting.

---

## 1. `gold.dim_customers`

**Purpose:** Stores customer attributes enriched with demographic and geographic information to support customer segmentation and behavioural analysis.

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key uniquely identifying a customer record in the dimension table. |
| `customer_id` | INT | Source-system identifier for the customer. |
| `customer_number` | NVARCHAR(50) | Alphanumeric customer reference used to identify the customer in the source system. |
| `first_name` | NVARCHAR(50) | Customer's first name. |
| `last_name` | NVARCHAR(50) | Customer's last name. |
| `country` | NVARCHAR(50) | Country associated with the customer's location. |
| `marital_status` | NVARCHAR(50) | Customer's marital status, such as Married or Single. |
| `gender` | NVARCHAR(50) | Customer's recorded gender, including standardised or unavailable values where applicable. |
| `birthdate` | DATE | Customer's date of birth. |
| `create_date` | DATE | Date the customer record was created in the source system. |

---

## 2. `gold.dim_products`

**Purpose:** Stores product attributes and category information to support product performance analysis, inventory reporting, and product classification.

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key uniquely identifying a product record in the dimension table. |
| `product_id` | INT | Source-system identifier for the product. |
| `product_number` | NVARCHAR(50) | Alphanumeric product code used to identify the product in the source system. |
| `product_name` | NVARCHAR(50) | Descriptive name of the product. |
| `category_id` | NVARCHAR(50) | Identifier linking the product to its product category. |
| `category` | NVARCHAR(50) | High-level classification of the product. |
| `subcategory` | NVARCHAR(50) | More specific classification within the product category. |
| `maintenance_required` | NVARCHAR(50) | Indicates whether the product requires maintenance, where applicable. |
| `cost` | INT | Recorded product cost in the source data's monetary units. |
| `product_line` | NVARCHAR(50) | Product line or classification, such as Road, Mountain, or Touring. |
| `start_date` | DATE | Date from which the product record becomes effective. |
| `end_date` | DATE | Date on which the product record ceases to be effective, where applicable. |

---

## 3. `gold.fact_sales`

**Purpose:** Stores sales transaction line items and their associated customer, product, and date keys. It supports revenue analysis, sales trends, and product and customer performance reporting.

**Grain:** One row per sales order line item.

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | NVARCHAR(50) | Identifier of the sales order associated with the transaction line. |
| `product_key` | INT | Foreign key linking the sales record to `gold.dim_products`. |
| `customer_key` | INT | Foreign key linking the sales record to `gold.dim_customers`. |
| `order_date` | DATE | Date the order was placed. |
| `shipping_date` | DATE | Date the order was shipped. |
| `due_date` | DATE | Scheduled due date associated with the order. |
| `sales_amount` | INT | Recorded sales value for the order line, in the source data's monetary units. |
| `quantity` | INT | Number of product units included in the order line. |
| `price` | INT | Recorded unit price for the product on the order line. |

---

## Notes

- **Surrogate keys:** Dimension keys such as `customer_key` and `product_key` provide warehouse-specific identifiers for linking fact records to dimensions.
- **Source identifiers:** Columns such as `customer_id` and `product_id` retain identifiers from the source systems.
- **Fact table grain:** `gold.fact_sales` is defined at the order-line level, so an order number may appear in multiple rows when an order contains multiple products or line items.
- **Date fields:** The product dimension's `start_date` and `end_date` can represent the validity period of a product record. Confirm this interpretation against the transformation logic.
- **Data types and definitions:** The descriptions above should be validated against the actual Gold Layer DDL. Monetary columns using `INT` store whole numbers and may not preserve fractional currency amounts.

