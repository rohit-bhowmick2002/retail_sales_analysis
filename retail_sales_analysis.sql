-- SQL Retail Sales Analysis - P1

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

SELECT * FROM retail_sales LIMIT 10;

SELECT 
    COUNT(*) 
FROM retail_sales;



-- Data Cleaning  extract null values
--SELECT * FROM retail_sales
--WHERE transactions_id IS NULL;

--SELECT * FROM retail_sales
--WHERE sale_date IS NULL

--SELECT * FROM retail_sales
--WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;



-- Delete null values
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;


	-- Data Exploration

	-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales;


-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales;


SELECT DISTINCT category FROM retail_sales;




-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';



-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4;



-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;



-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';



-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000;



-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1;



-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1;



-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category;



-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift;



--Q11. Find repeat customers (customers who purchased more than once)

SELECT customer_id, COUNT(*) AS total_orders
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) > 1;



-- Q12. Find customer lifetime value (CLV)

SELECT customer_id,
       SUM(total_sale) AS lifetime_value
FROM retail_sales
GROUP BY customer_id
ORDER BY lifetime_value DESC;



-- Q13. Find daily revenue trend

SELECT sale_date,
       SUM(total_sale) AS daily_revenue
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;



-- Q14. Find top category per month

SELECT year, month, category, total_sales
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        category,
        SUM(total_sale) AS total_sales,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
            ORDER BY SUM(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY year, month, category
) t
WHERE rnk = 1;




--Q15. Find month-over-month growth
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_sale) AS revenue
    FROM retail_sales
    GROUP BY 1, 2
)

SELECT 
    year,
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY year, month) AS prev_month,
    revenue - LAG(revenue) OVER (ORDER BY year, month) AS growth
FROM monthly_sales
ORDER BY year, month;



--Q16. Segment customers (High, Medium, Low spenders)

SELECT customer_id,
       SUM(total_sale) AS total_spent,
       CASE 
           WHEN SUM(total_sale) > 5000 THEN 'High'
           WHEN SUM(total_sale) BETWEEN 2000 AND 5000 THEN 'Medium'
           ELSE 'Low'
       END AS segment
FROM retail_sales
GROUP BY customer_id;



--Q17. Find most popular purchase time (hour)

SELECT 
    EXTRACT(HOUR FROM sale_time) AS hour,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY hour
ORDER BY total_orders DESC;



--Q18. Find average basket size (avg items per transaction)

SELECT AVG(quantity) AS avg_items_per_order
FROM retail_sales;



--Q19. Find retention (customers who purchased in multiple months)

SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM sale_date)) > 1;



--Q20. Find top 3 products (categories) per gender

SELECT *
FROM (
    SELECT 
        gender,
        category,
        SUM(total_sale) AS total_sales,
        RANK() OVER (
            PARTITION BY gender
            ORDER BY SUM(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY gender, category
) t
WHERE rnk <= 3;



--Q21. Find contribution % of each category

SELECT 
    category,
    SUM(total_sale) AS total_sales,
    ROUND(
        (SUM(total_sale) * 100.0 / 
        (SELECT SUM(total_sale) FROM retail_sales))::NUMERIC,
        2
    ) AS contribution_percent
FROM retail_sales
GROUP BY category;



--Q22. Find anomalies (very high sales compared to average)

SELECT *
FROM retail_sales
WHERE total_sale > (
    SELECT AVG(total_sale) * 3 FROM retail_sales
);



--Q23. Find first purchase date of each customer

SELECT customer_id,
       MIN(sale_date) AS first_purchase
FROM retail_sales
GROUP BY customer_id;



--Q24. Find last purchase date of each customer

SELECT customer_id,
       MAX(sale_date) AS last_purchase
FROM retail_sales
GROUP BY customer_id;



--Q25. Find customers who stopped purchasing (inactive)

SELECT customer_id,
       MAX(sale_date) AS last_purchase
FROM retail_sales
GROUP BY customer_id
HAVING MAX(sale_date) < '2022-10-01';




-- Advance Analysis

--Q1. Cohort Analysis (Customer Retention by First Purchase Month)
		--Problem:Track how many customers return in later months after their first purchase.

WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(DATE_TRUNC('month', sale_date)) AS cohort_month
    FROM retail_sales
    GROUP BY customer_id
),
activity AS (
    SELECT 
        r.customer_id,
        DATE_TRUNC('month', r.sale_date) AS activity_month
    FROM retail_sales r
)
SELECT 
    f.cohort_month,
    a.activity_month,
    COUNT(DISTINCT a.customer_id) AS active_customers
FROM first_purchase f
JOIN activity a 
    ON f.customer_id = a.customer_id
GROUP BY f.cohort_month, a.activity_month
ORDER BY f.cohort_month, a.activity_month;




--Q2. Customer Retention Rate
		--Problem: What % of customers return next month?

WITH monthly_customers AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS month,
        customer_id
    FROM retail_sales
    GROUP BY month, customer_id
),
retained AS (
    SELECT 
        m1.month,
        COUNT(DISTINCT m1.customer_id) AS current_month,
        COUNT(DISTINCT m2.customer_id) AS retained_customers
    FROM monthly_customers m1
    LEFT JOIN monthly_customers m2
        ON m1.customer_id = m2.customer_id
        AND m2.month = m1.month + INTERVAL '1 month'
    GROUP BY m1.month
)
SELECT 
    month,
    current_month,
    retained_customers,
    ROUND(
        (retained_customers * 100.0 / current_month)::NUMERIC,
        2
    ) AS retention_rate
FROM retained;



--Q3. Churned Customers
-- Problem: Find customers who did NOT return after their last purchase.

SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING MAX(sale_date) < (
    SELECT MAX(sale_date) - INTERVAL '30 days'
    FROM retail_sales
);




--Q4. Market Basket (Frequently Bought Together)
-- Problem: Which categories are purchased together?

SELECT 
    r1.category AS category_1,
    r2.category AS category_2,
    COUNT(*) AS frequency
FROM retail_sales r1
JOIN retail_sales r2
    ON r1.transactions_id = r2.transactions_id
    AND r1.category < r2.category
GROUP BY category_1, category_2
ORDER BY frequency DESC;



--Q5. Running Total Revenue
-- Problem: Track cumulative revenue over time

SELECT 
    sale_date,
    SUM(total_sale) AS daily_revenue,
    SUM(SUM(total_sale)) OVER (ORDER BY sale_date) AS running_total
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;



--Q6. Top Customers per Month
-- Problem: Find best customer each month

SELECT *
FROM (
    SELECT 
        DATE_TRUNC('month', sale_date) AS month,
        customer_id,
        SUM(total_sale) AS total_spent,
        RANK() OVER (
            PARTITION BY DATE_TRUNC('month', sale_date)
            ORDER BY SUM(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY month, customer_id
) t
WHERE rnk = 1;



--Q7. Sales Contribution by Top 20% Customers (Pareto Rule)
-- Problem: Do top 20% customers generate 80% revenue?

WITH customer_sales AS (
    SELECT 
        customer_id,
        SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY customer_id
),
ranked AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY total_spent DESC) AS bucket
    FROM customer_sales
)
SELECT 
    bucket,
    SUM(total_spent) AS revenue
FROM ranked
GROUP BY bucket
ORDER BY bucket;



--Q8. Peak Sales Day of Week
-- Problem: Which day generates highest revenue?

SELECT 
    TO_CHAR(sale_date, 'Day') AS day,
    SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY day
ORDER BY revenue DESC;



--Q9. Average Days Between Purchases
-- Problem: Customer buying frequency

WITH purchase_gap AS (
    SELECT 
        customer_id,
        sale_date,
        LAG(sale_date) OVER (
            PARTITION BY customer_id 
            ORDER BY sale_date
        ) AS prev_date
    FROM retail_sales
)
SELECT 
    customer_id,
    AVG(sale_date - prev_date) AS avg_days_between_orders
FROM purchase_gap
WHERE prev_date IS NOT NULL
GROUP BY customer_id;



--Q10. Identify Declining Customers
-- Problem: Customers whose spending is decreasing

WITH monthly_spend AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_sale) AS spend
    FROM retail_sales
    GROUP BY customer_id, month
),
trend AS (
    SELECT *,
        LAG(spend) OVER (
            PARTITION BY customer_id 
            ORDER BY month
        ) AS prev_spend
    FROM monthly_spend
)
SELECT *
FROM trend
WHERE spend < prev_spend;



-- End of project