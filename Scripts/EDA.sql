/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

use Datawarehouse ;

-- Retrive a list of all tables in a database 

select * from INFORMATION_SCHEMA.TABLES;

-- retrive all columns fora specific tables (dim_customers)

select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customers';

/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate

select distinct country from gold.dim_customers
order by country;


-- Retrieve a list of unique categories, subcategories, and products

select distinct category from gold.dim_products;

select category ,subcategory , product_name from gold.dim_products;

/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
select order_date from gold.fact_sales; 

select 
min(order_date) as first_order_date,
max(order_date) as last_order_date,
datediff(year, min(order_date),max(order_date)) as order_range_year,
datediff(month, min(order_date),max(order_date)) as order_range_month
from gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
select 
min(birthdate) as oldest_birthdate,
datediff(year, min(birthdate) , getdate()) as oldest_age,
max(birthdate) as youngest_birthdate,
datediff(year, max(birthdate) , getdate()) as youngest_age
from gold.dim_customers;


/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
select sum(sales_amount) from gold.fact_sales;

-- Find how many items are sold
select sum(quantity) from gold.fact_sales;

-- Find the average selling price
select avg(price) from gold.fact_sales; -- avg price quite high

-- Find the Total number of Orders
select count(order_number) from gold.fact_sales; -- there are 60k total order (some repeated)
select count( distinct order_number) from gold.fact_sales; -- there are 27k distinct orders

-- Find the total number of products
select count( distinct order_number) from gold.fact_sales; -- 295 products


-- Find the total number of customers
select count(customer_key) from gold.dim_customers; -- total 18484 customers
select count(distinct customer_key) from gold.dim_customers; -- same 18484



-- Find the total number of customers that has placed an order
select count(distinct customer_key ) from gold.dim_customers; -- used customer_key becoz its a PK


-- Generate a Report that shows all key metrics of the business

select 'Total Sales' as measure_name , sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'Total Quantity' as measure_name , sum(quantity) from gold.fact_sales
union all
select 'Average Price' as measure_name , AVG(price) from gold.fact_sales
union all
select 'Total Orders' as measure_name , count( distinct order_number) from gold.fact_sales
union all
select 'Total Products' as measure_name , count( distinct order_number) from gold.fact_sales
union all
select 'Total customers' as measure_name , count(customer_key) from gold.dim_customers;


/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries
select 
country,
count(customer_key) as total_customers
from gold.dim_customers
group by country
order by total_customers desc;

-- Find total customers by gender
select 
gender,
count(customer_key) as total_customers
from gold.dim_customers
group by gender
order by total_customers desc;

-- Find total products by category
select category,
count(product_key) as total_product
from gold.dim_products
group by category
order by total_product desc;

select category,subcategory,
count(product_key) as total_product
from gold.dim_products
group by category ,subcategory
order by total_product desc;
 

-- What is the average costs in each category?
select category,
avg(cost) as avg_cost
from gold.dim_products
group by category
order by avg_cost desc;


-- What is the total revenue generated for each category?
select category,
sum(price) as Total_revenue
from gold.fact_sales f
join  gold.dim_products p on f.product_key = p.product_key 
group by category
order by Total_revenue;

select category,
sum(sales_amount) as Total_revenue
from gold.fact_sales f
join  gold.dim_products p on f.product_key = p.product_key 
group by category
order by Total_revenue;

-- What is the total revenue generated by each customer?
select 
    c.customer_key ,
    first_name,
    last_name,
    sum(price) as Total_revenue
from gold.fact_sales f
join  gold.dim_customers c on f.customer_key = c.customer_key 
group by 
    c.customer_key ,
    first_name,
    last_name
order by Total_revenue desc;


-- What is the distribution of sold items across countries?

select 
    c.country,
    sum(quantity) as sold_items
from gold.fact_sales f
left join gold.dim_customers c on c.customer_key = f.customer_key
group by c.country
order by sold_items desc;

/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking

select top 5
product_name,
sum(sales_amount) as Total_revenue
from gold.fact_sales f
join  gold.dim_products p on f.product_key = p.product_key 
group by product_name
order by Total_revenue desc;

-- Complex but Flexibly Ranking Using Window Functions

select *
from (
    select 
    product_name,
    sum(sales_amount) as Total_revenue,
    row_number() over (order by sum(sales_amount) desc ) as rank_products
    from gold.fact_sales f
    join  gold.dim_products p on f.product_key = p.product_key 
    group by product_name) t
where rank_products <= 5;   -- SQL does not allow you to filter window functions so we used subquery 
-- below is example of cte 

/*
 ===== CTE ======
WITH RankedProducts AS (
    SELECT 
        product_name,
        SUM(sales_amount) AS Total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key 
    GROUP BY product_name
)
SELECT * 
FROM RankedProducts
WHERE rank_products <= 5;

*/


-- What are the 5 worst-performing products in terms of sales?
select top 5
product_name,
sum(sales_amount) as Total_revenue
from gold.fact_sales f
join  gold.dim_products p on f.product_key = p.product_key 
group by product_name
order by Total_revenue ;

-- What are the 5 worst-performing subactegory in terms of sales?


select top 5
subcategory,
sum(sales_amount) as Total_revenue
from gold.fact_sales f
join  gold.dim_products p on f.product_key = p.product_key 
group by subcategory
order by Total_revenue ;
-- Find the top 10 customers who have generated the highest revenue

SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;
-- The 3 customers with the fewest orders placed

SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ;
