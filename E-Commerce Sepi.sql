-- E-Commerce Sepi
-- You applied for the Data Analyst position at e-commerce Sepi. You are asked to answer several questions by writing SQL statements.
-- You are given 3 tables: user, performance, and order.

-- Overview Table Columns
-- user_tab: shopid, buyerid, register_date, country
-- performance_tab: shopid, total_clicks, impressions, item_views
-- order_tab: shopid, orderid, buyerid, itemid, gmv, order_time

-- Question 1
-- First and last order for each customer in every shop
-- each cust = buyerid, each shop = shopid, first order = MIN(order_time), last order = MAX(order_time)
SELECT buyerid, shopid, MIN(order_time) AS first_order, MAX(order_time) AS last_order
FROM order_tab
GROUP BY buyerid, shopid
ORDER BY buyerid, 3;


-- Question 2
-- Find buyers who made more than one order in a single month
-- count total orders per buyer per month that are > 1
SELECT buyerid, COUNT(EXTRACT (MONTH FROM order_time)) AS total_order
FROM order_tab
GROUP BY buyerid
HAVING COUNT(EXTRACT(MONTH FROM order_time)) > 1;


-- Question 3
-- Find the first buyer in each shop
SELECT shopid, buyerid, MIN(order_time) AS first_order
FROM order_tab
GROUP BY shopid, buyerid;

-- Incorrect because it only returns the earliest time, not which buyer was first
-- Fix
SELECT buyerid
FROM order_tab
WHERE order_time = MIN(order_time) IN THAT SHOP

-- Method 1
WITH first_buyer AS (
	SELECT shopid, buyerid, order_time,
		MIN(order_time) OVER (PARTITION BY shopid) AS first_order
	FROM order_tab
	ORDER BY shopid ASC, 3
)
SELECT DISTINCT shopid, buyerid, first_order
FROM first_buyer
WHERE order_time = first_order;
-- Want to know all buyers who placed the first order at the same time
-- Because filtering order_time = first_order can produce >1 buyer
-- Method 1 says: “Who all showed up at the earliest time?”


-- Method 2
WITH first_order AS (
	SELECT shopid, buyerid, order_time,
	FIRST_VALUE(buyerid) OVER(PARTITION BY shopid ORDER BY order_time) AS first_buyer,
	FIRST_VALUE(order_time) OVER(PARTITION BY shopid ORDER BY order_time) AS first_order
FROM order_tab
ORDER BY shopid ASC, 3
)
SELECT DISTINCT shopid, first_buyer, first_order FROM first_order;
-- Just want to know one first buyer per shop
-- Because FIRST_VALUE() directly picks the first one based on order
-- Method 2 says: “Just who came first, only one person.”


-- QUESTION 4
-- Find the TOP 10 buyers based on GMV with country codes: ID and SG
-- calculate total GMV per buyer who placed orders
-- filter buyers from ID and SG, select top 10

-- Create a temporary table to efficiently store buyer and country data.
CREATE TEMPORARY TABLE user_country AS
	SELECT DISTINCT buyerid, country FROM user_tab;

SELECT * FROM user_country;

WITH top_ten AS (
	SELECT ot.buyerid, SUM(gmv) AS total_gmv FROM order_tab AS ot
	JOIN user_country AS uc ON ot.buyerid = uc.buyerid
	WHERE country IN ('ID', 'SG')
	GROUP BY ot.buyerid
	ORDER BY 2 DESC
	LIMIT 10
)
SELECT * FROM top_ten
JOIN user_country USING(buyerid)
ORDER BY 2 DESC;


-- Question 5
-- Find the count of buyers in each country who placed orders with odd and even itemid (itemid data type is int)
-- Count buyers in each country based on itemid parity (odd/even)
-- Get info of buyers who placed orders, count even_item and odd_item

-- Method 1
SELECT country,
COUNT(CASE WHEN itemid % 2 = 0 THEN orderid ELSE NULL END) AS even_order,
COUNT(CASE WHEN itemid % 2 != 0 THEN orderid ELSE NULL END) AS odd_order
FROM order_tab AS ot
JOIN user_country USING(buyerid)
GROUP BY 1;
-- Only counting itemids where orderid is not NULL

-- Method 2
SELECT country,
SUM(CASE WHEN itemid % 2 = 0 THEN 1 ELSE 0 END) AS even_order,
SUM(CASE WHEN itemid % 2 != 0 THEN 1 ELSE 0 END) AS odd_order
FROM order_tab AS ot
JOIN user_country USING(buyerid)
GROUP BY 1;
-- Counting all itemids that meet condition regardless of NULL in orderid
-- Safer if orderid might contain NULL


-- Question 6
-- Analyze Conversion Rate (orders/views) & Click Through Rate (clicks/impressions) for each shop (in a single query)
-- Find total views, clicks, impressions per shop (performance_tab)
-- JOIN subquery: find total orders for each shop (order_tab)
-- Calculate CVR (total_order / total_views) and CTR (total_clicks / total_impressions)
SELECT DISTINCT shopid,
				n_order,
				SUM(total_clicks) OVER(PARTITION BY shopid) AS sum_tc,
				SUM(item_views) OVER(PARTITION BY shopid) AS sum_tv,
				SUM(impressions) OVER(PARTITION BY shopid) AS sum_imp,
				n_order::NUMERIC / SUM(item_views) OVER(PARTITION BY shopid) AS cvr,
				SUM(total_clicks) OVER(PARTITION BY shopid)::NUMERIC / SUM(impressions)
				OVER(PARTITION BY shopid) AS ctr
FROM performance_tab AS pt
JOIN (SELECT shopid, COUNT(orderid) AS n_order FROM order_tab AS ot GROUP BY shopid) AS order_count_per_shop
USING(shopid)
ORDER BY 1 ASC;
