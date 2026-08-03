/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

use DataWareHouse;

-- Analyse sales performance over time
-- Quick Date Functions

select 
    year(order_date) as order_year,
    month(order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_key ) as total_customer,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date) , month(order_date)
order by year(order_date) , month(order_date); -- by year and month

select 
    year(order_date) as order_year,
    sum(sales_amount) as total_sales,
    count(distinct customer_key ) as total_customer,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);


-- DATETRUNC()
select
    datetrunc (month,order_date) as order_date,
    sum(sales_amount) as total_sales,
    count(distinct customer_key ) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by datetrunc (month,order_date) 
order by datetrunc (month,order_date) ;

select
    datetrunc (year,order_date) as order_date,
    sum(sales_amount) as total_sales,
    count(distinct customer_key ) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by datetrunc (year,order_date) 
order by datetrunc (year,order_date) ;

-- FORMAT()

select 
    format(order_date, 'yyyy-MMM') as order_date,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customer,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by format(order_date, 'yyyy-MMM') 
order by format(order_date, 'yyyy-MMM') ; 










































































































