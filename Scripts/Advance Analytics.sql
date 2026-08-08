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




===============================================================================
--Cumulative Analysis
===============================================================================



--SQL Functions Used:
    -- Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================

-- Calculate the total sales per month 
-- and the running total of sales over time 


select 
     order_date,
     total_sales,
     avg_price,
     sum(total_sales) over (order by Order_date) as runnig_total_sales,
     avg(avg_price) over (order by order_date) as moving_average_price
from
(
    select
        DATETRUNC(MONTH, order_date) as order_date,
        sum(sales_amount) as total_sales,
        avg(price) as avg_price

    from gold.fact_sales
    where order_date is not null
    group by datetrunc(MONTH,order_date)
    ) t;

select 
     order_date,
     total_sales,
     avg_price,
     sum(total_sales) over (order by Order_date) as runnig_total_sales,
     avg(avg_price) over (order by order_date) as moving_average_price
from
(
    select
        DATETRUNC(year, order_date) as order_date,
        sum(sales_amount) as total_sales,
        avg(price) as avg_price

    from gold.fact_sales
    where order_date is not null
    group by datetrunc(year,order_date)
    ) t;



/*
===== Insights =======================
1. Total_sales Insight: Revenue peaked heavily in 2013 at 16.34M before experiencing an extreme
99.7% collapse in 2014, signaling either a major business disruption or incomplete data.

2. avg_price Insight: Product pricing underwent a massive downward trajectory, falling from 
high-ticket levels in 2010 (3,101) to mass-market/discount levels by 2014 (23).

3. runnig_total_sales Insight: Over 99% of total lifetime revenue (~29.35M) was accumulated during 
a tight 3-year window between 2011 and 2013, with growth completely flattening in 2014.

4. moving_average_price Insight: The baseline historical price continually eroded over time, 
dropping nearly 47% from its peak of 3,146 down to 1,668 due to low recent unit prices.
*/


/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

/* divide the question first 
 see what we need = order_date, products and sales_amount
 in years and summ of sales  then put it in cte

 then current sales , avg sales , pervioys year sales using window function
 */
 with yearly_product_sales as (
     select 
        year(f.order_date) as order_year,
        p.product_name,
        sum(f.sales_amount) as current_sales
    from gold.fact_sales f
    left join gold.dim_products p
        on f.product_key = p.product_key
    where order_date is not null
    group by
        year(f.order_date),
        p.product_name
)
select  
    order_year,
    product_name,
    current_sales,
    avg(current_sales) over (partition by product_name) as avg_sales,
    current_sales - avg(current_sales) over (partition by product_name) as diff_avg,

    case
        when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above avg'
        when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'below avg'
        else 'SAME'
    end as avg_change,
    -- year over year analysis
   lag(current_sales) over (partition by product_name order by order_year) as py_sales,
   current_sales - lag(current_sales) over (partition by product_name order by order_year) as diff_py,
   case
       when current_sales - lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
       when current_sales - lag(current_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'   
       else 'No change'
   end as py_change
from yearly_product_sales
order by product_name, order_year;

/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?

 
 with category_sales as (
	select 
	p.category,
	sum(f.sales_amount) as total_sales
	from gold.fact_sales f
	left join gold.dim_products p
		on p.product_key = f.product_key
	group by p.category)

select 
	category,
	total_sales,
	sum(total_sales) over () as overall_sales,
	concat(round((cast(total_sales as float)/  sum(total_sales) over ()) * 100 ,2 ), '%') as percentage_of_total
from category_sales
order by total_sales desc;

/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/



