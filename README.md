🛒 Sales & Returns Analysis (SQL + Power BI)
📌 Project Overview

This project demonstrates an end-to-end data analysis :

Raw sales data was cleaned and structured in PostgreSQL using SQL.

Data was connected to Power BI for interactive dashboarding.

Final dashboards provide executive insights, customer & product analysis, and returns analysis.

The goal is to simulate a real-world business intelligence project that helps management track performance and optimize business decisions.

🗂️ Dataset & Tables

The project uses 5 main tables:

Customers → Customer details (name, email, region, etc.)

Products → Product details (name, category, price)

Orders → Customer purchases (date, product, quantity, status)

Returns → Returned orders (date, reason)

Regions → Region mapping

🛠️ Data Cleaning (SQL)

Data preprocessing was done in PostgreSQL:

Removed duplicate customers (same email → smallest CustomerID kept).

Filled missing categories (using product name reference).

Fixed invalid/missing order dates (default year 1900 handled separately).

Deleted records with invalid foreign keys (e.g., Orders without valid CustomerID).

Ensured primary & foreign key relationships across tables.

👉 Cleaned SQL scripts are available in the sql_scripts/ folder.

📊 Dashboards (Power BI)
1️⃣ Executive Summary Dashboard

Total Net Sales (Orders – Returns)

Total Customers & Orders

Sales Trend (line chart: month/year)

Regional Sales (bar chart)

Category-wise Sales (Pie chart)

2️⃣ Customer & Product Analysis Dashboard

Top 10 Customers by Sales (bar chart)

Top 10 Products by Sales (bar chart)

10 Low-Selling Products (bar chart)

3️⃣ Returns & Order Analysis Dashboard

Return Rate % (KPI)

Highest & Lowest Return Rate Product (KPI cards)

Reasons for Returns (bar chart)

Returned Orders Trend (line chart)

Orders by Status (Pending, Delivered, Cancelled)

📈 Key Insights

Sales peaked during festive months.

A few high-value customers contribute to the majority of revenue.

Electronics & Accessories had the highest sales share.

Product return rate is X%, with most returns due to wrong item/damaged item.

⚙️ Tech Stack

SQL (PostgreSQL) → Data cleaning & preparation

Power BI → Data visualization & dashboarding

GitHub → Project documentation & sharing

🚀 How to Use

