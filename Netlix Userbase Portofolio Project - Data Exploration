-- Netflix Userbase Data Exploration

--------------------------------------------------------------------------------------------------------------------------

-- Load the table
SELECT * FROM netflix_userbase;

-- Create a new table for cleaned dates
CREATE TABLE NetflixUserbase AS
SELECT 
    User_ID, 
    Subscription_Type, 
    Monthly_Revenue,
    STR_TO_DATE(Join_Date, '%d-%m-%y') AS JoinDate,
    STR_TO_DATE(Last_Payment_Date, '%d-%m-%y') AS LastPaymentDate,
    Country, 
    Age, 
    Gender, 
    Device, 
    Plan_Duration
FROM datasets.netflix_userbase;

--------------------------------------------------------------------------------------------------------------------------

-- Load the new table
SELECT * FROM netflixuserbase;


-- Total users for each Device type
SELECT Device,
	COUNT(*) AS Total_User,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM netflixuserbase) * 100,2) AS User_Percent
FROM netflixuserbase
GROUP BY Device
ORDER BY Total_User DESC;


-- Total users and revenue for each subscription types
SELECT Subscription_Type,
    COUNT(*) * SUM(Monthly_Revenue) AS Total_Revenue,
    AVG(Monthly_Revenue) AS Avg_Revenue,
    ROUND(((COUNT(*) / (SELECT COUNT(*) FROM netflix_userbase)) * 100),2) AS Subs_Type_Dist
FROM netflixuserbase
GROUP BY Subscription_Type;


--  Calculate Churn Rate by Subscription Type:
SELECT Subscription_Type,
	COUNT(*) AS Total_User,
    SUM(CASE WHEN MONTH(LastPaymentDate) = 6 THEN 1 ELSE 0 END) AS Churned_Users,
    (COUNT(*) - SUM(CASE WHEN MONTH(LastPaymentDate) = 7 THEN 1 ELSE 0 END)) / COUNT(*) *100 as Churn_Rate
FROM netflixuserbase
GROUP BY Subscription_Type;

-- Gender distribution among users
SELECT Gender,
	COUNT(*) AS User_Count,
	ROUND(((COUNT(*) / (SELECT COUNT(*) FROM netflix_userbase)) * 100),2) AS Gender_Percent,
    ROUND(AVG(Age),2) AS Avg_Age
FROM netflixuserbase
GROUP BY Gender;


-- Identify user by age distribution, subs duration, and churn rate
SELECT Age, 
	COUNT(*) AS Total_User,
   	AVG(FLOOR(DATEDIFF(LastPaymentDate, JoinDate)/30)) AS Subs_Duration,
	(COUNT(*) - SUM(CASE WHEN MONTH(LastPaymentDate) = 7 THEN 1 ELSE 0 END)) / COUNT(*) *100 as Churn_Rate 
FROM netflixuserbase
GROUP BY Age
ORDER BY Age;


-- Identify country-wise revenue from each country
SELECT Country,
	SUM(FLOOR(DATEDIFF(LastPaymentDate, JoinDate)/30) * Monthly_Revenue) AS Total_Payment,
    SUM(FLOOR(DATEDIFF(LastPaymentDate, JoinDate)/30) * Monthly_Revenue) / COUNT(*) AS Average_Spending_per_Country
FROM netflixuserbase
GROUP BY Country
ORDER BY 2 DESC;


-- Identify Country-wise user and churn rate
SELECT Country,
	COUNT(*) AS Total_Users,
    (COUNT(*) - SUM(CASE WHEN MONTH(LastPaymentDate) = 7 THEN 1 ELSE 0 END)) / COUNT(*) *100 as Churn_Rate
FROM netflixuserbase
GROUP BY Country
ORDER BY 2 DESC;


-- New users per year 
SELECT YEAR(JoinDate) AS Join_Year,
    COUNT(*) AS Total_User
FROM datasets.netflixuserbase
GROUP BY Join_Year
ORDER BY Join_Year;


-- New users by month year 
SELECT MONTH(JoinDate) AS Join_Month,
    COUNT(*) AS Total_User
FROM datasets.netflixuserbase
GROUP BY Join_Month
ORDER BY Join_Month;


-- Total users who start subscribed, in per month timeline 
SELECT YEAR(JoinDate) AS Join_Year,
    MONTH(JoinDate) AS Join_Month,
    COUNT(*) AS Total_User
FROM datasets.netflixuserbase
GROUP BY Join_Year, Join_Month
ORDER BY Join_Year, Join_Month;
