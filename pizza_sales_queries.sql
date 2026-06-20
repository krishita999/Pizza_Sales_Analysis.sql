-- Retrieve the total number of orders placed.

SELECT COUNT(*) AS total_order
FROM pizzahut.orders;

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM pizzas AS p
JOIN order_details AS od
	ON p.pizza_id = od.pizza_id ;
    
-- Identify the highest-priced pizza.

SELECT pt.name , p.price
FROM pizzas AS p
JOIN pizza_types AS pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1 ;

-- Identify the most common pizza size ordered.

SELECT p.size , COUNT(od.quantity) AS order_count
FROM pizzas AS p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT (pt.name) , SUM(od.quantity) AS total_quantity
FROM pizzas AS p
JOIN pizza_types AS pt
	ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od
	ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category , SUM(od.quantity) AS quantity
FROM pizzas AS p
JOIN pizza_types AS pt
	ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od
	ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC ; 

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(time) AS Hour , COUNT(order_id) AS Count
FROM orders
GROUP BY Hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category , COUNT(name)
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(Avg_Quantity),0)
FROM
(SELECT o.date AS Date, SUM(od.quantity) AS Avg_Quantity
FROM orders AS o
JOIN order_details AS od
	ON o.order_id = od.order_id 
GROUP BY Date) AS t;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name , SUM(p.price * o.quantity) AS Revenue  
FROM pizza_types AS pt
JOIN pizzas AS p
	ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS o
	ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category , ROUND(SUM(p.price * od.quantity) / (SELECT ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM pizzas AS p
JOIN order_details AS od
	ON p.pizza_id = od.pizza_id) * 100 ,2 )AS Revenue
FROM pizzas AS p
JOIN pizza_types AS pt
	ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od
	ON od.pizza_id = p.pizza_id  
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.

SELECT date , SUM(Revenue) OVER(ORDER BY date) AS Cum_Revenue
FROM
(SELECT o.date , SUM(p.price * od.quantity) AS Revenue
FROM pizzas AS p
JOIN order_details AS od
	ON p.pizza_id = od.pizza_id 
JOIN orders AS o
	ON o.order_id = od.order_id
GROUP BY o.date) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name , category , Revenue
FROM 
(SELECT name , category ,Revenue, RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS Rn
FROM
(SELECT pt.name , pt.category , SUM(p.price * od.quantity) AS Revenue
FROM pizzas AS p
JOIN order_details AS od
	ON p.pizza_id = od.pizza_id 
JOIN pizza_types AS pt
	ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name , pt.category) AS a) AS b
WHERE Rn <= 3;








