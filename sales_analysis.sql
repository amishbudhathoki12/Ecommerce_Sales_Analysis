--1.  Checking if the data is loaded in postgresql and selecting 10 data from sales table

Select *
From sales
LIMIT 5 --
--
--Columns
--invoice_no
--stock_code
--description
--quantity
--unit_price
--customer_id
--country
--invoice_day_month_year
--invoice_time
--revenue
--
--KPI Analysis
--1. Total Revenue (How much money did the business generate)

SELECT ROUND(SUM(revenue)::NUMERIC, 2) as total_revenue
from sales --
--
--2. Total orders (how many total unique orders did the customer make)

SELECT COUNT(DISTINCT invoice_no) AS total_orders
FROM sales --
--
--3. Total Customers (How many total unique customers are there)

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM sales --
--
--4. Total sold products(How many products were sold in total)

SELECT SUM(quantity) as total_items_sold
FROM sales --
--
--5. Average order value(what is the average order value by revenue)

SELECT ROUND((SUM(revenue)/ COUNT(DISTINCT invoice_no))::NUMERIC, 2) AS avg_order_value
FROM sales --
--
-- Product Analysis
--1. Top 10 best selling products (Highest number of products sold)

SELECT description,
       stock_code,
       SUM(quantity) AS units_sold
FROM sales
GROUP BY description,
         stock_code
ORDER BY units_sold DESC
Limit 10--
--
--2. Top 10 Products by revenue (Highest revenue generating  products)

SELECT stock_code,
       description,
       ROUND(SUM(revenue)::NUMERIC, 2) AS total_revenue
FROM sales
GROUP BY description,
         stock_code
ORDER BY total_revenue DESC
LIMIT 10;

--
--3. Products generating low revenue (Lowest revenue generating products)

SELECT stock_code,
       description,
       ROUND(SUM(revenue)::NUMERIC, 3) AS total_revenue
FROM sales
GROUP BY description,
         stock_code
ORDER BY total_revenue ASC
LIMIT 10--
--
-- Customer Analysis
--1. Top Customers by Spending (VIP Customers)

SELECT customer_id,
       ROUND(SUM(revenue)::NUMERIC, 2) AS total_spent
FROM sales
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10--
--
--2.  Loyal Customer

SELECT customer_id,
       COUNT(DISTINCT invoice_no) AS total_orders
FROM sales
GROUP BY customer_id
HAVING COUNT(DISTINCT invoice_no) >= 10
ORDER BY total_orders DESC--
--
--3. One time customer (customer who bought the product once)

SELECT COUNT(*) AS one_time_customers
FROM
     (SELECT customer_id,
             COUNT(DISTINCT invoice_no) AS orders
      FROM sales
      GROUP BY customer_id
      HAVING COUNT(DISTINCT invoice_no)=1) AS one_time;

--4. Repeat Customers and retention rate (How manu customers came back)

SELECT COUNT(*) AS repeat_customers
FROM
     (SELECT customer_id,
             COUNT(DISTINCT invoice_no)
      FROM sales
      GROUP BY customer_id
      HAVING COUNT(DISTINCT invoice_no) > 1)--
-- repeated customer percentage

SELECT ROUND(COUNT(CASE
                       WHEN order_count > 1 THEN 1
                   END) * 100.0 / COUNT(*), 2) AS repeat_customer_percentage
FROM
     (SELECT customer_id,
             COUNT(DISTINCT invoice_no) AS order_count
      FROM sales
      GROUP BY customer_id)--
--
--5. Customer Segment according to the total spending(VIP, High Value and Regular)

SELECT customer_id,
       ROUND(SUM(revenue)::NUMERIC, 2) AS total_spent,
       CASE
           WHEN SUM(revenue)> 5000 THEN 'VIP'
           WHEN SUM(revenue) > 1000 THEN 'High Value'
           ELSE 'Regular'
       END AS customer_segment
FROM sales
GROUP BY customer_id--
--
-- Geographic Analysis
--1. Which country has the highest revenue

SELECT country,
       ROUND(SUM(revenue)::NUMERIC, 2) AS total_revenue
FROM sales
GROUP BY country
ORDER BY total_revenue DESC --
--
--2. Which country has the highest orders

SELECT country,
       COUNT(DISTINCT invoice_no) AS orders_by_country
FROM sales
GROUP BY country
ORDER BY orders_by_country DESC--
--
--3. Average Order Value by Country

SELECT country,
       ROUND((SUM(revenue) / COUNT(DISTINCT invoice_no))::numeric, 2) AS average_order_value
FROM sales
GROUP BY country
ORDER BY average_order_value DESC--
--
--4. Best products by country
 WITH product_sales AS
     (SELECT country,
             description,
             SUM(quantity) AS units_sold
      FROM sales
      GROUP BY country,
               description),
      ranked_products AS
     (SELECT country,
             description,
             units_sold,
             RANK() OVER(PARTITION BY country
                         ORDER BY units_sold DESC) AS rank
      FROM product_sales)
SELECT *
FROM ranked_products
WHERE rank <= 5--
--
-- Time Based analysis
--1. Monthly Revenue Trend (How did revenue changed month by month)

     SELECT DATE_TRUNC('month', TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS month,
            ROUND(SUM(revenue)::Numeric, 2) AS monthly_revenue
     FROM sales
GROUP BY month
ORDER BY month--
--
--2. Monthly orders trend

SELECT DATE_TRUNC('month', TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS month,
       COUNT(DISTINCT invoice_no) AS total_orders
FROM sales
GROUP BY month
ORDER BY month --
--
--3. Best Sales Month (Which month generated the highest revenue)

SELECT DATE_TRUNC('month', TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS month,
       ROUND(SUM(revenue)::NUMERIC, 2) AS revenue
FROM sales
GROUP BY month
ORDER BY revenue DESC
LIMIT 1--
--
--4. Worst sales Month (which month generated the lowest revenue)

SELECT DATE_TRUNC('month', TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS month,
       ROUND(SUM(revenue)::NUMERIC, 2) AS revenue
FROM sales
GROUP BY month
ORDER BY revenue ASC
LIMIT 1--
--
--5. Daily sales pattern (Which day of the week perform better)

SELECT TRIM(TO_CHAR(TO_DATE(invoice_day_month_year, 'DD/MM/YYYY'), 'Day')) AS day_name,
       ROUND(SUM(revenue)::NUMERIC, 2) AS revenue
FROM sales
GROUP BY day_name
ORDER BY revenue DESC--
--
-- Customer Behavior Analysis
--1. Purchase Frequeuncy (How often does each customer purchase)

SELECT customer_id,
       COUNT(DISTINCT invoice_no) AS purchase_frequency
FROM sales
GROUP BY customer_id
ORDER BY purchase_frequency DESC--
--
--2. Average purchase Frequency (On average how many times does a customer purchase)

SELECT ROUND(AVG(purchase_frequency), 4) AS avg_purchase_frequency
FROM
     (SELECT customer_id,
             COUNT(DISTINCT invoice_no) AS purchase_frequency
      FROM sales
      GROUP BY customer_id) AS customer_frequency --
--
--3. Customer Lifetime Value(CLV) (How much does a customer generate during their relationship with business)

SELECT customer_id,
       ROUND(SUM(revenue)::NUMERIC, 2) AS CLV
FROM sales
GROUP BY customer_id
ORDER BY CLV DESC--
--
--4. Recency Frequency Monetary(RFM) Analysis
 WITH rfm AS
     (SELECT customer_id,
             DATE '2011-12-10' - MAX(TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS recency,
             COUNT(DISTINCT invoice_no) AS frequency,
             ROUND(SUM(revenue)::NUMERIC, 2) AS monetary
      FROM sales
      GROUP BY customer_id)
SELECT customer_id,
       recency,
       frequency,
       monetary,
       NTILE(5) OVER(
                     ORDER BY recency DESC) AS recency_score,
       NTILE(5) OVER(
                     ORDER BY frequency) AS frequency_score,
       NTILE(5) OVER(
                     ORDER BY monetary) AS monetary_score
FROM rfm--
--
--5. Customer Segments According to RFM Scores (Champions, Loyal, Big spenders, At risk and regular)
WITH rfm AS
     (SELECT customer_id,
             DATE '2011-12-10' - MAX(TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS recency,
             COUNT(DISTINCT invoice_no) AS frequency,
             SUM(revenue) AS monetary
      FROM sales
      GROUP BY customer_id),
     scores AS
     (SELECT *,
             NTILE(5) OVER(
                           ORDER BY recency DESC) AS r_score,
             NTILE(5) OVER(
                           ORDER BY frequency) AS f_score,
             NTILE(5) OVER(
                           ORDER BY monetary) AS m_score
      FROM rfm)
SELECT customer_id,
       r_score,
       f_score,
       m_score,
       CASE
           WHEN r_score >=4
                AND f_score >=4
                AND m_score >=4 THEN 'Champions'
           WHEN f_score >=4 THEN 'Loyal Customers'
           WHEN m_score >=4 THEN 'Big Spenders'
           WHEN r_score <=2
                AND f_score >=3 THEN 'At Risk'
           ELSE 'Regular Customers'
       END AS customer_segment
FROM scores--
--
-- Data Quality / Business Checks
--1. Cancelled Order Analysis

SELECT COUNT(*) AS cancelled_transactions
FROM original_sales
WHERE "Quantity" < 0--
--
--2. Lost Revenue from cancellations

     Select ROUND(SUM("Quantity" * "UnitPrice")::NUMERIC, 2) AS cancelled_revenue
     FROM original_sales WHERE "Quantity" < 0--
--
--3. Most returned products (Which products are returned the most)

     SELECT "Description",
            ABS(SUM("Quantity")) AS returned_quantity
     FROM original_sales WHERE "Quantity" < 0
GROUP BY "Description"
ORDER BY returned_quantity DESC
LIMIT 10--
--
--4. Biggest orders

SELECT invoice_no,
       ROUND(SUM(revenue)::NUMERIC, 2) AS order_value
FROM sales
GROUP BY invoice_no
ORDER BY order_value DESC
LIMIT 10;

--
--5. Unusually large quantity purchases

SELECT invoice_no,
       description,
       quantity
FROM sales
ORDER BY quantity DESC
LIMIT 10--
--
--6. Which products makes the most revenue (Product revenue concentration)

SELECT description,
       ROUND(SUM(revenue)::NUMERIC, 2) AS revenue
FROM sales
GROUP BY description
ORDER BY revenue DESC
LIMIT 10--
 --
--7. Pareto Analysis (Do 20% product generate 80% revenue)
WITH product_sales AS
     (SELECT description,
             ROUND(SUM(revenue)::NUMERIC, 2) AS revenue
      FROM sales
      GROUP BY description),
     ranked AS
     (SELECT description,
             revenue, -- Corrected: The OVER clause belongs strictly to the SUM() function
 ROUND(((SUM(revenue) OVER(
                           ORDER BY revenue DESC) / SUM(revenue) OVER()) * 100)::NUMERIC, 2) AS cumulative_percentage
      FROM product_sales)
SELECT *
FROM ranked
WHERE cumulative_percentage <= 80--
--
--8. Customer Revenue Concentration
WITH customer_sales AS
          (SELECT customer_id,
                  ROUND(SUM(revenue)::NUMERIC, 2) AS revenue
           FROM sales
           GROUP BY customer_id),
     ranked AS
          (SELECT customer_id,
                  revenue,
                  ROUND((SUM(revenue) OVER(
                                           ORDER BY revenue DESC) / SUM(revenue) OVER() *100)::NUMERIC, 2) AS cumulative_percentage
           FROM customer_sales)
     SELECT *
     FROM ranked WHERE cumulative_percentage <=80;

------
------
------
------
----------VIEWS FOR VIZUALIZATION---------------
--vizualization for kpi cards

CREATE VIEW kpi_summary AS
SELECT ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
       COUNT(DISTINCT invoice_no) AS total_orders,
       COUNT(DISTINCT customer_id) AS total_customers,
       SUM(quantity) AS total_items_sold,
       ROUND((SUM(revenue)/ COUNT(DISTINCT invoice_no))::NUMERIC, 2) AS avg_order_value
FROM sales;


SELECT *
FROM kpi_summary;

--vizualization for monthly revenue

CREATE VIEW monthly_revenue AS
SELECT DATE_TRUNC('month', TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS month,
       ROUND(SUM(revenue)::Numeric, 2) AS monthly_revenue
FROM sales
GROUP BY month
ORDER BY month;


SELECT *
FROM monthly_revenue;

--Vizualization for monthly orders

CREATE VIEW monthly_orders AS
SELECT DATE_TRUNC('month', TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS month,
       COUNT(DISTINCT invoice_no) AS total_orders
FROM sales
GROUP BY month
ORDER BY month;


SELECT *
FROM monthly_orders;

--Vizualization for Top 10 products by revenue

CREATE VIEW top_products_revenue AS
SELECT stock_code,
       description,
       ROUND(SUM(revenue)::NUMERIC, 2) AS total_revenue
FROM sales
GROUP BY description,
         stock_code
ORDER BY total_revenue DESC
LIMIT 10;


SELECT *
FROM top_products_revenue;

--Vizualization for Top 10 products by quantity

CREATE VIEW top_products_quantity AS
SELECT description,
       stock_code,
       SUM(quantity) AS units_sold
FROM sales
GROUP BY description,
         stock_code
ORDER BY units_sold DESC
Limit 10;


SELECT *
FROM top_products_quantity;

--Vizualization for highest value customers

CREATE VIEW top_customers AS
SELECT customer_id,
       ROUND(SUM(revenue)::NUMERIC, 2) AS total_spent
FROM sales
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;


SELECT *
FROM top_customers;

--Vizualization for Customer Segmentation by RFM

CREATE VIEW rfm_segments AS WITH rfm AS
     (SELECT customer_id,
             DATE '2011-12-10' - MAX(TO_DATE(invoice_day_month_year, 'DD/MM/YYYY')) AS recency,
             COUNT(DISTINCT invoice_no) AS frequency,
             SUM(revenue) AS monetary
      FROM sales
      GROUP BY customer_id),
                                 scores AS
     (SELECT *,
             NTILE(5) OVER(
                           ORDER BY recency DESC) AS r_score,
             NTILE(5) OVER(
                           ORDER BY frequency) AS f_score,
             NTILE(5) OVER(
                           ORDER BY monetary) AS m_score
      FROM rfm)
SELECT customer_id,
       r_score,
       f_score,
       m_score,
       CASE
           WHEN r_score >=4
                AND f_score >=4
                AND m_score >=4 THEN 'Champions'
           WHEN f_score >=4 THEN 'Loyal Customers'
           WHEN m_score >=4 THEN 'Big Spenders'
           WHEN r_score <=2
                AND f_score >=3 THEN 'At Risk'
           ELSE 'Regular Customers'
       END AS customer_segment
FROM scores;


SELECT *
FROM rfm_segments;

--Vizualization for Customer Retention

CREATE VIEW customer_retention AS WITH customer_orders AS
     (SELECT customer_id,
             COUNT(DISTINCT invoice_no) AS total_orders
      FROM sales
      WHERE customer_id IS NOT NULL
      GROUP BY customer_id)
SELECT CASE
           WHEN total_orders = 1 THEN 'One-Time Customers'
           WHEN total_orders > 1 THEN 'Repeated Customers'
       END AS customer_type,
       COUNT(*) AS customers
FROM customer_orders
GROUP BY customer_type;


SELECT *
FROM customer_retention;

--Vizualization for Revenue By Country

CREATE VIEW country_revenue AS
SELECT country,
       ROUND(SUM(revenue)::numeric, 2) AS total_revenue
FROM sales
GROUP BY country
ORDER BY total_revenue DESC;


SELECT *
FROM country_revenue;

--Vizualization for Orders By Country

CREATE VIEW country_orders AS
SELECT country,
       COUNT(DISTINCT invoice_no) AS total_orders
FROM sales
GROUP BY country
ORDER BY total_orders DESC;


SELECT *
FROM country_orders;

--Vizualization for Products pareto

CREATE VIEW product_pareto AS WITH product_sales AS
     (SELECT description,
             ROUND(SUM(revenue)::numeric, 2) AS revenue
      FROM sales
      GROUP BY description),
                                   ranked AS
     (SELECT description,
             revenue,
             ROUND((SUM(revenue) OVER(
                                      ORDER BY revenue DESC) / SUM(revenue) OVER() *100)::numeric, 2) AS cumulative_percentage
      FROM product_sales)
SELECT *
FROM ranked
ORDER BY revenue DESC;


SELECT *
FROM product_pareto;