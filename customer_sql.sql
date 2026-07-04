ALTER USER 'root'@'localhost'
IDENTIFIED WITH mysql_native_password
BY 'root';
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost'
IDENTIFIED WITH mysql_native_password
BY 'root';
FLUSH PRIVILEGES;

SELECT user, host, plugin
FROM mysql.user
WHERE user = 'root';

ALTER USER 'root'@'127.0.0.1'
IDENTIFIED WITH mysql_native_password
BY 'root';

ALTER USER 'root'@'%'
IDENTIFIED WITH mysql_native_password
BY 'root';

FLUSH PRIVILEGES;

SELECT * FROM customers;

-- Q1 What is the total revenue genereated by male vs female customers
SELECT gender,SUM(purchase_amount) AS 'Revenue' FROM customers
GROUP BY gender;

-- Q2 Which customers used a discount but still spent more than the average puchare amount
SELECT customer_id,purchase_amount FROM customers 
WHERE discount_applied = 'Yes'
AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customers);

-- Q3 Which are the top 5 products with the highest average review rating
SELECT item_purchased, ROUND(AVG(review_rating),2) AS 'Average Product Rating' FROM customers 
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;


-- Q4 Compare the average purchase amounts between standard and express shipping 
SELECT shipping_type,ROUND(AVG(purchase_amount),2) from customers 
WHERE shipping_type in ('Standard','Express')
GROUP BY shipping_type;

-- Q5 Do subscribed customers spend more? Compare average spend and total revenue between subscribers and non subscribers
SELECT subscription_status,COUNT(customer_id) as 'Total_Customers', ROUND(AVG(purchase_amount),2) as 'Average_spend',SUM(purchase_amount) as 'Total_Revenue'
FROM customers
GROUP BY subscription_status;

-- Q6 Which 5 products have the highest percentage of puchases with discounts applied?
SELECT item_purchased,ROUND(100 * SUM( CASE WHEN discount_applied ='YES' THEN 1 ELSE 0 END)/COUNT(*) ,2)  AS 'discount_rate'
FROM customers 
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7 Segment customers into NEW , RETURNING and LOYAL based on their total number of previous purchases, and show the count of each segment
WITH CTE AS (
SELECT customer_id,previous_purchases, 
CASE
	WHEN previous_purchases = 1 THEN 'NEW'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'RETURNING'
	ELSE 'LOYAL'
	END AS customer_segment 
FROM customers
)
SELECT customer_segment,COUNT(*) AS 'no_of_customers' FROM CTE
GROUP BY customer_segment;

-- Q8 What the top 3 most purchased products within each category
-- used row_number here as rank,dense_rank would put items of equal order value at same rank 

WITH item_counts AS (
SELECT category,item_purchased,COUNT(customer_id) AS 'total_orders',
ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS 'item_rank'
FROM customers
GROUP BY category,item_purchased )

SELECT item_rank,category,item_purchased,total_orders FROM item_counts
WHERE item_rank <= 3;

-- Q9 Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status, COUNT(customer_id) AS 'Repeat_buyers' FROM customers
WHERE previous_purchases >5
GROUP BY subscription_status;

-- Q10 What is the revenue contribution of each age group?
 SELECT age_group, SUM(purchase_amount) AS 'total_revenue'
FROM customers
GROUP BY age_group
ORDER BY total_revenue DESC