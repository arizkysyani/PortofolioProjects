SELECT * FROM datasets.online_retail_dataset;

-- Cheking data duplications using CONCAT
SELECT concat(InvoiceNo, StockCode, Description,Quantity, InvoiceDate, UnitPrice, CustomerID) as concat,
	count(distinct concat(InvoiceNo, StockCode, Description,Quantity, InvoiceDate, UnitPrice, CustomerID)) as count_concat
FROM online_retail_dataset
GROUP BY concat
HAVING count_concat > 1;
/* There are no duplicated values*/

-- Checking null or empty values

SELECT COUNT(*) 
FROM datasets.online_retail_dataset;
-- 541,909 counts

SELECT COUNT(*) 
FROM datasets.online_retail_dataset 
WHERE CustomerID is NULL;
-- 0 counts

SELECT COUNT(*) 
FROM datasets.online_retail_dataset
WHERE LENGTH(Description) = 0;
-- 1,454 counts

SELECT COUNT(*) 
FROM datasets.online_retail_dataset 
WHERE CustomerID = 0;
-- 135,080 counts

SELECT COUNT(*) 
FROM datasets.online_retail_dataset 
WHERE length(Description) != 0 AND CustomerID != 0;
-- 406,829 counts

/* There are 541,909 total rows with 0 Null. But there are 1,454 Description and 135,080 CustomerID rows where the data is empty. So there's 406,829 row with cleaned data. I'll be using this data for the visualization */ 

------------------------------------------------------------------------------------------------------------------------------------------
-- Exploratory Data Analysis

-- Top 10 purchasing country
SELECT Country, 
	count(InvoiceNo) AS total_transaction,
    count(InvoiceNo) / (SELECT count(*) FROM datasets.online_retail_dataset) * 100 AS percent
FROM datasets.online_retail_dataset 
GROUP BY Country 
ORDER BY 2 DESC
LIMIT 10;
/* UK has the highest number of transactions with 91.43%. This suggests that the majority of TATA Online Retail business is conducted in UK. */ 

-- Top 10 most buy item
SELECT Description,
	SUM(Quantity) AS total_qty_purchase
FROM datasets.online_retail_dataset
GROUP BY Description
ORDER BY total_qty_purchase DESC
LIMIT 10;
/* WORLD WAR 2 GLIDERS ASSTD DESIGNS is the highest quantity that customers bought */

-- 10 highest selling item
SELECT Description,
	SUM(Quantity * UnitPrice) AS total_purchase
FROM datasets.online_retail_dataset
GROUP BY Description
ORDER BY total_purchase DESC
LIMIT 10; 
/* DOTCOM POSTAGE and REGENCY CAKESTAND 3 TIER are the highest selling products in terms of revenue */ 

-- Total order by date
SELECT DAYNAME(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) AS day,
	COUNT(InvoiceNo) AS total_order_by_day
FROM datasets.online_retail_dataset
GROUP BY day
ORDER BY total_order_by_day DESC;
/* Customer tend to purchase from TATA Retail on thursday, and Sunday is the least favorite day to buy things. */

-- Purchase order by months
SELECT MONTHNAME(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) AS month,
	COUNT(DISTINCT InvoiceNo) AS total_order_by_month
FROM datasets.online_retail_dataset
GROUP BY month
ORDER BY total_order_by_month DESC;
/* Customer tend to buy stuff on Q4 (October - December) for holiday season, and has it peaks on November */

-- Churn rate analysis by month
WITH churn AS (
    SELECT
        InvoiceNo,
        CustomerID,
        DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%Y/%m/%d %H:%i'), '%Y-%m') AS date2
    FROM online_retail_dataset
)
SELECT
    date2,
    total_users,
    LAG(total_users) OVER (ORDER BY date2) AS previous_month_users,
    total_users - LAG(total_users) OVER (ORDER BY date2) AS lost_users,
    (LAG(total_users) OVER (ORDER BY date2) - total_users) / LAG(total_users) OVER (ORDER BY date2) * 100 as churn_rate
FROM (
    SELECT
        date2,
        COUNT(DISTINCT CustomerID) as total_users
    FROM churn
    GROUP BY date2
) AS churn_summary;
/* TATA Online Retail has stable total users ever month, and has more users every month since September to November 2011. There are lots of lost user in 2011 December because the latest date in the dataset is 9th December. */

-- Churn rate MTD 9th every month
WITH churn AS (
    SELECT
        InvoiceNo,
        CustomerID,
        DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%Y/%m/%d %H:%i'), '%Y-%m') AS date2,
        DAY(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) AS date
    FROM online_retail_dataset
    WHERE DAY(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) BETWEEN 1 AND 9
)
SELECT
    date2,
    total_users,
    LAG(total_users) OVER (ORDER BY date2) AS previous_month_users,
    total_users - LAG(total_users) OVER (ORDER BY date2) AS lost_users,
    (LAG(total_users) OVER (ORDER BY date2) - total_users) / LAG(total_users) OVER (ORDER BY date2) * 100 as churn_rate
FROM (
    SELECT
        date2,
        COUNT(DISTINCT CustomerID) as total_users
    FROM churn
    GROUP BY date2
) AS churn_summary;
/* Here is the data for churn rate with MTD 9th every month. It has stable and users and has increment of users every month */

-- Customer segmentation and retained customers
WITH customer_spending AS (
    SELECT
        CustomerID,
        SUM(UnitPrice * Quantity) AS total_spending
    FROM online_retail_dataset
    GROUP BY CustomerID)

SELECT
    CASE
        WHEN total_spending >= 1000 THEN 'High-Value'
        WHEN total_spending >= 500 THEN 'Medium-Value'
        ELSE 'Low-Value'
    END AS customer_segment,
    COUNT(DISTINCT online_retail_dataset.CustomerID) AS total_customers,
    COUNT(DISTINCT(CASE WHEN YEAR(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) = 2011 AND MONTH(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) = 12 THEN online_retail_dataset.CustomerID END)) AS retained_customers,
    (COUNT(DISTINCT(CASE WHEN YEAR(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) = 2011 AND MONTH(STR_TO_DATE(online_retail_dataset.InvoiceDate, '%Y/%m/%d %H:%i')) = 12 THEN online_retail_dataset.CustomerID END)) / COUNT(DISTINCT online_retail_dataset.CustomerID))*100 AS retention_rate
FROM customer_spending
JOIN online_retail_dataset ON customer_spending.CustomerID = online_retail_dataset.CustomerID
GROUP BY customer_segment;
/* Based on their spending, customers segment divided by 3 segments (Low, Medium, and High Value) with classification of:
0-499 GBP is Low-Value
500-999 GBP is Medium-Value
=> 1000 GBP is High-Value.

It suggests that the High-Value segment is performing well in terms of retention, while the Low-Value segment faces greater retention challenges. */