# 🛒 Olist End-to-End Data Analytics Project

> A complete end-to-end data analytics project built on the **Olist Brazilian E-Commerce & Marketing Funnel Dataset**, covering data modelling, SQL analytics, validation, and Power BI dashboards.

---

## 📌 Project Overview

This project simulates a **real-world data analytics pipeline** for Olist — Brazil's largest e-commerce marketplace. It covers everything from raw data ingestion and schema design to advanced SQL analysis and interactive Power BI dashboards.

The goal is to extract actionable business insights across:
- 🛍️ Customer behaviour & geography
- 📦 Order fulfilment & logistics performance
- 🏷️ Product & category profitability
- 💳 Payment trends & installment behaviour
- ⭐ Customer satisfaction & review analysis
- 📣 Marketing funnel & seller acquisition quality

---

## 🗂️ Project Structure

```
📦 Olist-End-to-End-Data-Analytics
│
├── 📁 SQL/
│   ├── E-commerce_Schema.sql               # Core e-commerce table definitions
│   ├── Marketing_Schema.sql                # Marketing funnel table definitions
│   ├── E-commerce_Data_Validation.sql      # Data quality & integrity checks
│   ├── Marketing_Funnel_Validation.sql     # Funnel data validation checks
│   ├── E-commerce_Analytical_Insights.sql  # Full analytical SQL queries
│   └── Marketing_Analytical_Insights.sql  # Marketing funnel SQL insights
│
├── 📁 Data_Models/
│   ├── ecommerce_star_schema.md            # Star schema design & rationale
│   └── marketing_data_model.md            # Funnel analytics data model
│
├── 📁 PowerBI/
│   └── Olist_Dashboard.pbix               # Power BI dashboard file
│
└── README.md
```

---

## 🗃️ Dataset

**Source:** [Olist Brazilian E-Commerce Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
**Marketing Funnel:** [Olist Marketing Funnel Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist)

### E-Commerce Tables

| Table | Rows | Description |
|-------|------|-------------|
| `olist_customers` | 99,441 | Customer info & location |
| `olist_orders` | 99,441 | Order lifecycle & timestamps |
| `olist_order_items` | 112,650 | Product-level order detail |
| `olist_order_payments` | 103,886 | Payment type & installments |
| `olist_order_reviews` | 99,224 | Customer reviews & scores |
| `olist_products` | 32,951 | Product attributes & dimensions |
| `olist_sellers` | 3,095 | Seller info & location |
| `olist_geolocation` | 1,000,163 | ZIP-level lat/lng coordinates |
| `product_category_name_translation` | 71 | Portuguese → English category mapping |

### Marketing Funnel Tables

| Table | Description |
|-------|-------------|
| `marketing_qualified_leads` | All MQLs — top of funnel |
| `marketing_closed_deals` | Converted sellers — bottom of funnel |

---

## 🏗️ Data Architecture

### E-Commerce: Star Schema

The e-commerce data is modelled as a **Star Schema** to support fast analytical queries and BI dashboards.

```
              Dim_Customers
                   |
              Dim_Orders
                   |
Dim_Products — Fact_Order_Items — Dim_Sellers
                   |
         Dim_Order_Payments
                   |
          Dim_Order_Reviews
                   |
           Dim_Geolocation
                   |
   Dim_Product_Category_Translation
```

**Fact Table:** `Fact_Order_Items`  
**Grain:** 1 row = 1 product item sold within 1 order  
**Why not `Orders`?** Most KPIs (revenue, freight, product performance) require item-level granularity.

📄 Full design details → [`ecommerce_star_schema.md`](Data_Models/ecommerce_star_schema.md)

---

### Marketing: Funnel Analytics Model

The marketing dataset uses a **Funnel Analytics Pattern** — not a star schema — because it represents a process flow, not repeated transactions.

```
marketing_qualified_leads  (Top of Funnel)
           |
           | mql_id
           |
marketing_closed_deals     (Bottom of Funnel)
```

📄 Full design details → [`marketing_data_model.md`](Data_Models/marketing_data_model.md)

---

## 📊 Analytical Insights — SQL

### A. Customer & Geography Analysis
- States and cities with highest customer volume
- Percentage of repeat customers
- Top 10 highest-spending customers (CLV proxy)
- Revenue contribution by state

### B. Order & Logistics Performance
- Estimated vs actual delivery gap
- Count and percentage of late deliveries
- Sellers with best/worst shipping performance
- States with slowest average delivery times
- Delivery time distribution per product category

### C. Product & Category Analytics
- Units sold and revenue by category
- Average price and freight cost by category
- Correlation between product weight and price
- Weight-bucket price analysis
- Late delivery rate per category
- Top 10 most profitable categories

### D. Payment Analysis
- Most common payment methods
- Installment range distribution
- Percentage of multiple-installment payments
- Revenue and average order value by payment type

### E. Review & Customer Satisfaction
- Average review score overall
- Impact of late delivery on review scores
- Review score distribution (1–5)
- Lowest-rated product categories
- Best and worst-rated sellers
- Average time to respond to customer reviews

### F. Marketing Funnel Insights
- MQL → Closed Deal conversion rate
- Conversion rate by lead origin
- Revenue by business type
- Seller quality indicators (company registration, GTIN)
- Seller geography vs declared revenue
- Acquisition quality vs delivery performance

---

## ✅ Data Validation

Thorough data validation was performed before analysis. Key checks included:

**E-Commerce:**
- NULL checks across all tables
- Duplicate primary key detection
- Timestamp logic checks (approval before purchase, delivery before carrier, etc.)
- Price/freight sanity checks
- Geographic coordinate range validation (Brazil bounds)
- Order status consistency

**Marketing Funnel:**
- Duplicate MQL ID detection
- Deal date vs lead date consistency
- Seller linkage integrity (MQL → Olist sellers)
- Revenue sanity checks (min/max, % with non-zero revenue)
- Funnel integrity: MQLs without closed deals

---

## 📈 Power BI Dashboard

An interactive Power BI dashboard was built on top of this analytical layer, featuring:

- 🗺️ **Geographic maps** — customer & seller distribution across Brazil
- 📦 **Logistics performance** — delivery time trends, late delivery rates
- 🏷️ **Category performance** — revenue, units sold, avg price
- 💳 **Payment analysis** — payment type split, installment trends
- ⭐ **Customer satisfaction** — review score distribution, delivery impact
- 📣 **Marketing funnel** — MQL to deal conversion, lead origin performance

> **File:** `PowerBI/Olist_Dashboard.pbix`  
> Requires Power BI Desktop to open.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **PostgreSQL** | Database & SQL analytics |
| **Python (psycopg2, pandas)** | Data ingestion & loading |
| **Power BI Desktop** | Dashboard & visualisation |
| **SQL** | Data validation, transformation, analysis |
| **Markdown** | Data modelling documentation |

---

## 🚀 How to Run

### 1. Set up PostgreSQL Database
```sql
CREATE DATABASE "Olist-end-to-end-data-analytics";
```

### 2. Create Schemas & Tables
```bash
psql -d "Olist-end-to-end-data-analytics" -f SQL/E-commerce_Schema.sql
psql -d "Olist-end-to-end-data-analytics" -f SQL/Marketing_Schema.sql
```

### 3. Load Data (Python)
```bash
pip install pandas psycopg2
python scripts/load_data.py
```

### 4. Run Validation Checks
```bash
psql -d "Olist-end-to-end-data-analytics" -f SQL/E-commerce_Data_Validation.sql
psql -d "Olist-end-to-end-data-analytics" -f SQL/Marketing_Funnel_Validation.sql
```

### 5. Run Analytical Queries
```bash
psql -d "Olist-end-to-end-data-analytics" -f SQL/E-commerce_Analytical_Insights.sql
psql -d "Olist-end-to-end-data-analytics" -f SQL/Marketing_Analytical_Insights.sql
```

### 6. Open Power BI Dashboard
Open `PowerBI/Olist_Dashboard.pbix` in Power BI Desktop and connect to your local PostgreSQL instance.

---

## 💡 Key Business Insights

- **São Paulo (SP)** dominates in both customer volume and total revenue.
- **Late deliveries** have a measurable negative impact on review scores — on-time orders average ~4.0 vs ~2.5 for late ones.
- **Credit card** is the dominant payment method, with the majority of customers using installments.
- **Bed/bath/table** and **health & beauty** are top revenue-generating categories.
- **Only ~8% of MQLs** convert into active sellers — organic search leads convert best.
- Sellers with **registered companies** report significantly higher declared monthly revenue than unregistered ones.

---

## 👨‍💻 Author

**Mohammad Taib Khan**  
Data Analyst | SQL · Power BI · Python  



---

## 📄 License

This project uses publicly available datasets from Kaggle (Olist).  
All SQL, data models, and dashboard work is original.

---

*Built as a portfolio project to demonstrate end-to-end analytics skills — from raw data to business insights.*
