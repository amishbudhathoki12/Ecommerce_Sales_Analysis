# 🛒 E-Commerce Sales Analysis

## 📌 Project Overview

This project analyzes an e-commerce transaction dataset to understand business performance, customer behavior, product performance, and sales trends.

The project follows a complete data analytics workflow:

- Data cleaning using Python (Pandas)
- Business analysis using PostgreSQL and SQL queries
- Data visualization using Matplotlib and Seaborn

The goal is to generate meaningful business insights that can help improve sales strategies, customer retention, and decision-making.

---

# 🛠️ Tools & Technologies

- Python
  - Pandas
  - Matplotlib
  - Seaborn

- PostgreSQL
  - SQL Queries
  - Views
  - Aggregations
  - Window Functions

- Jupyter Notebook

- SQLAlchemy

---

# 📂 Project Structure

```
E-Commerce-Analysis/

│
├── ecommerce_analysis.ipynb
│   └── Data cleaning and preprocessing
│
├── e_commerce_sales_visualization.ipynb
│   └── Data visualization and dashboard creation
│
├── sales_analysis.sql
│   └── Business analysis SQL queries
│
├── cleaned_ecommerce.csv
│   └── Cleaned dataset
│
└── README.md
```

---

# 🧹 Data Cleaning

The original dataset contained:

- Missing customer IDs
- Missing product descriptions
- Duplicate records
- Invalid quantities
- Invalid unit prices

Cleaning steps performed:

✅ Removed duplicate transactions  
✅ Removed negative quantities  
✅ Removed zero/negative prices  
✅ Removed missing customer IDs  
✅ Filled missing descriptions  
✅ Created revenue column  
✅ Converted date columns into usable formats  

Final cleaned dataset:

- Rows: 392,692
- Columns: 10

---

# 🗄️ Database Analysis (PostgreSQL)

The cleaned dataset was loaded into PostgreSQL for business analysis.

Analysis included:

## 📊 Business KPIs

- Total Revenue
- Total Orders
- Total Customers
- Total Items Sold
- Average Order Value


## 📦 Product Analysis

Questions answered:

- Which products sell the most?
- Which products generate the most revenue?
- Which products contribute most to total sales?


## 👥 Customer Analysis

Performed:

- Top customers by spending
- Repeat customer analysis
- One-time customer analysis
- Customer Lifetime Value (CLV)


## 🎯 RFM Customer Segmentation

Customers were segmented using:

### Recency
How recently customers purchased

### Frequency
How often customers purchased

### Monetary
How much customers spent


Customer segments:

- Champions
- Loyal Customers
- Big Spenders
- At Risk Customers
- Regular Customers


## 🌍 Geographic Analysis

Analyzed:

- Revenue by country
- Orders by country
- Product performance by country


## 📈 Time-Based Analysis

Analyzed:

- Monthly revenue trends
- Monthly order trends
- Best sales month
- Daily sales patterns


## 📦 Business Quality Checks

Analyzed:

- Cancelled orders
- Returned products
- Revenue concentration
- Large purchases

---

# 📊 Visualizations

Created visualizations using Matplotlib and Seaborn:

- KPI Dashboard
- Monthly Revenue Trend
- Monthly Orders Trend
- Top Products by Revenue
- Top Products by Quantity
- Customer Segmentation
- Repeat vs One-Time Customers
- Country Performance
- Revenue Concentration Analysis


---

# 💡 Key Business Insights

The analysis helps answer:

- Which products drive revenue?
- Who are the most valuable customers?
- Are customers returning?
- Which countries perform best?
- Which products should receive more attention?
- How concentrated is revenue among products and customers?

---

# 🚀 Future Improvements

Possible improvements:

- Create an interactive dashboard using Power BI/Tableau
- Automate data pipeline
- Add predictive sales forecasting
- Build customer recommendation system


---

# 📚 Dataset

## Dataset

The original dataset contains 392,692 cleaned transaction records.

Due to GitHub file size limitations, the full dataset is not included.

A sample dataset (`sample_ecommerce.csv`) is provided for preview.

Original dataset source:
Kaggle E-Commerce Dataset
https://www.kaggle.com/datasets/carrie1/ecommerce-data
---

# 👨‍💻 Author

Amish Budhathoki

Data Analytics Project
