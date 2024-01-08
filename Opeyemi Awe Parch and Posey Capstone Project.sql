SELECT * FROM accounts
SELECT * FROM orders
SELECT * FROM region
SELECT * FROM sales_reps
SELECT * FROM web_events

---QUERY 1. I want to write a query to know the lists of all marketing channels 
-----------in which Parch and Posey distribute information about the product.
SELECT Distinct channel AS a
FROM web_events

---QUERY 2. I want to have details of the best and worst performing marketing channel
--------to know which channel the company needs to invest more in.
SELECT channel, COUNT(*) AS total_count
FROM web_events
GROUP by channel 
ORDER BY total_count DESC;

---QUERY 3. I want to write a query to identify companies in order of patronage. 
-----This will help us know the companies that should be rewarded for higher patronage
------and to encourage companies with lower rates.
with stg_customers AS (SELECT accounts.id AS id, accounts.name AS name ,
COUNT(orders.id)AS order_count FROM orders
JOIN accounts ON accounts.id = orders.account_id
GROUP BY 1, 2)
SELECT *, round((CAST(order_count AS numeric)/CAST((SELECT 
MAX (order_count)FROM stg_customers) AS numeric)),2) AS max_orders 
FROM stg_customers 
ORDER BY max_orders DESC;


----QUERY 4. I want to write a query to identify companies in order of patronage. 
--This will help us know the companies that should be rewarded for higher patronage 
--and to encourage companies with lower rates.
SELECT s.id AS sales_rep_id, s.name AS sales_rep_name,
r.name AS region,
COUNT(DISTINCT a.id) AS no_of_customers,
COUNT(o.id) AS no_of_orders,
SUM(o.total_amt_usd) AS total_revenue
FROM accounts a
JOIN orders o ON a.id = o.account_id
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
GROUP BY 1,2,3
ORDER BY 6 DESC;

---QUERY 5. A query that provides the sales rep. from Northeast with their
--associated accounts.The regional manager needs a table that shows the region’s name,
--the sales rep. name and account name for analysis.

SELECT s.name sales_rep, r.name  region, 
a.name accounts, a.id account_id
FROM sales_reps s
JOIN region r ON r.id = s.region_id
JOIN accounts a ON s.id = a.sales_rep_id
WHERE r.name = 'Northeast'
and a.name IS NOT NULL
ORDER BY 1,3;
 
 --- QUERY 6. A query that provides the sales_rep for west region along with their number of customers and total revenue.
 
 SELECT s.id as sales_rep_id, s.name AS sales_rep_name, r.name AS region,
 COUNT(DISTINCT a.id) AS no_of_customers,
 COUNT(o.id) AS no_of_orders,
 SUM(o.total_amt_usd) AS total_revenue
 FROM accounts a
 JOIN orders o ON a.id = o.account_id
 JOIN sales_reps s ON a.sales_rep_id = s.id
 JOIN region r ON r.id = s.region_id
 WHERE r.name = 'West'
 GROUP BY 1,2,3
 ORDER BY 4 DESC
 
 --QUERY 7. A query to fetch the names of top 10 companies that order more than 50 products. 
 --The company wants to reward customers who have been consistent and to know their
 --preferred product.

with stg_purchases AS (SELECT a.id,a. name, COUNT (o.id)
AS order_count, SUM(standard_qty) AS standard_qty, 
SUM (gloss_qty) AS gloss_qty,
SUM(poster_qty) AS poster_qty,
SUM(total_amt_usd)AS total_amt_usd
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY 1,2)
SELECT * FROM stg_purchases
WHERE order_count > 50
ORDER BY order_count DESC
LIMIT 10;
