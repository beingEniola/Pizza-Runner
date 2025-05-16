SELECT * FROM runners;
SELECT * FROM runner_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_topping;
SELECT * FROM customer_orders;

-- A. Pizza Metrics

-- Q.1 How many pizzas were ordered? '

SELECT COUNT(order_id) 
FROM customer_orders;

-- Q.2 How many unique customer orders were made? 
SELECT COUNT(DISTINCT order_id)
FROM customer_orders;

-- Q.3 How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id)
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

--Q.4 How many of each type of pizza was delivered?
SELECT c.pizza_id, COUNT(*)
FROM runner_orders r
JOIN customer_orders c
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY c.pizza_id;

--Q.5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, 
	SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meatlovers_orders, 
    SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegeterians_orders
FROM customer_orders 
GROUP BY customer_id
ORDER BY customer_id

--Q.6 What was the maximum number of pizzas delivered in a single order?
SELECT MAX(no_of_pizzas) 
FROM 
	( SELECT order_id, COUNT(pizza_id) no_of_pizzas
		FROM customer_orders
		GROUP BY order_id
	);
	
--Q.7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id, 
		COUNT(CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 END) AS changes,
		COUNT(CASE WHEN c.exclusions IS NULL AND c.extras IS  NULL THEN 1 END) AS no_changes
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id
ORDER BY c.customer_id

--Q.8 How many pizzas were delivered that had both exclusions and extras?

SELECT 
	COUNT(pizza_id) AS exclusion_n_extras_change
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL AND c.exclusions IS NOT NULL AND c.extras IS NOT NULL

-- Q.9 What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time:: TIMESTAMP) AS hour, 
		COUNT(order_id)
FROM customer_orders
GROUP By hour
ORDER BY hour;

-- Q.10 What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time:: TIMESTAMP, 'Day') AS Weekday, 
		COUNT(order_id)
FROM customer_orders
GROUP By Weekday
ORDER BY Weekday;

-- B. Runner and Customer Experience

-- Q.11 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT TO_CHAR(registration_date, 'ww') AS Week,
		COUNT(runner_id)
FROM runners
GROUP BY Week
ORDER BY Week;

/* Q.12 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ 
to pickup the order? */

WITH time_taken AS (
    SELECT r.runner_id, r.pickup_time, c.order_time, 
        EXTRACT(MINUTE FROM AGE(r.pickup_time,c.order_time)) AS pickup_minutes
FROM runner_orders r
    JOIN customer_orders c
    ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY r.runner_id, r.pickup_time, c.order_time
ORDER BY r.runner_id
)

SELECT runner_id, ROUND(AVG(pickup_minutes)::NUMERIC) AS avg_pickup_duration
FROM time_taken
GROUP BY runner_id;

-- Q.13 Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH prep_time AS (
SELECT c.order_id, COUNT(c.order_id) AS pizza_order, r.pickup_time, c.order_time,
    EXTRACT(MINUTE FROM AGE(r.pickup_time,c.order_time)) AS prep_minutes
FROM runner_orders r
JOIN customer_orders c
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id, r.pickup_time, c.order_time
)

SELECT pizza_order, ROUND(AVG(prep_minutes), 0) AS avg_prep_time
FROM prep_time
GROUP BY pizza_order;

-- Q.14 What was the average distance travelled for each customer?

SELECT c.customer_id, ROUND(AVG(r.distance), 0) AS avg_distance
FROM runner_orders r
JOIN customer_orders c
ON r.order_id = c.order_id
GROUP BY c.customer_id;

-- Q.15 What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS delivery_range
FROM runner_orders

/* Q.16 What was the average speed for each runner for each delivery and do you notice any trend 
	for these values? */
	
SELECT runner_id, order_id, ROUND(AVG(distance/duration * 60), 2) AS avg_speed
FROM runner_orders
WHERE duration IS NOT NULL
GROUP BY runner_id, order_id
ORDER BY runner_id;

--Q.17 What is the successful delivery percentage for each runner?
SELECT runner_id, 
	ROUND(COUNT(CASE WHEN cancellation IS NULL THEN 1 END)::NUMERIC/COUNT(*)::NUMERIC * 100) AS delivery_rate
FROM runner_orders r
GROUP BY runner_id


-- Q.18 What are the standard ingredients for each pizza?
SELECT n.pizza_name, t.topping_name
FROM pizza_recipes re
JOIN pizza_names n
ON re.pizza_id = n.pizza_id
JOIN pizza_topping t
ON t.topping_id = ANY(string_to_array(re.toppings, ',')::INT[])

-- Q.19 What was the most commonly added extra?
WITH extras_cte AS (
				SELECT pizza_id, unnest(string_to_array(extras, ','))::INT AS extras
FROM customer_orders
)

SELECT extras, t.topping_name, COUNT(extras) AS extras_count
FROM extras_cte e
JOIN pizza_topping t 
ON t.topping_id = e.extras
GROUP BY extras, t.topping_name
ORDER BY extras_count DESC

--Q.20 What was the most common exclusion?
WITH exclusion_cte AS 
				(SELECT pizza_id, 
					  unnest(string_to_array(exclusions, ','))::INT AS exclusions
				FROM customer_orders)
					  
SELECT exclusions, topping_name, COUNT(exclusions) AS exclusion_counts
FROM exclusion_cte e
JOIN pizza_topping t
ON e.exclusions= t.topping_id
GROUP BY exclusions, topping_name
ORDER BY exclusion_counts DESC

/* Q.21 Generate an order item for each record in the customers_orders table 
                    in the format of one of the following: */

SELECT order_id, pizza_id, exclusions, extras, 
		CASE WHEN pizza_id = 1 AND exclusions IS NULL AND extras IS NULL THEN 'Meatlovers'
		WHEN pizza_id = 2 AND exclusions IS NULL AND extras IS NULL THEN 'Vegetarian'
        WHEN pizza_id = 1 AND exclusions = '4' AND extras IS NULL THEN 'Meatlovers - Exclude Cheese'
		WHEN pizza_id = 2 AND exclusions = '4' AND extras IS NULL THEN 'Vegetarian - Exclude Cheese'
        WHEN pizza_id = 1 AND exclusions IS NULL AND extras = '1' THEN 'Meatlovers - Extra Bacon'
        WHEN pizza_id = 2 AND exclusions IS NULL AND extras = '1' THEN 'Vegetarian - Extra Bacon'
        WHEN pizza_id = 1 AND exclusions = '4' AND extras = '1, 5' THEN 'Meatlovers - Exclude Cheese - Extra Bacon, Chicken'
        WHEN pizza_id = 1 AND exclusions = '2, 6' AND extras = '1, 4' THEN 'Meatlovers - Exclude BBQ Sauce, Mushroom - Extra Bacon, Cheese'
        END AS order_item
FROM customer_orders c

/* Q.22 Generate an alphabetically ordered comma separated ingredient list for each pizza order 
	 from the customer_orders table and add a 2x in front of any relevant ingredients */
		 
WITH base_toppings AS (
  SELECT c.order_id,c.customer_id, c.pizza_id, 
    c.exclusions, c.extras, t.topping_id, t.topping_name
  FROM customer_orders c
  JOIN pizza_recipes r 
    ON c.pizza_id = r.pizza_id
  JOIN pizza_topping t 
    ON t.topping_id = ANY (string_to_array(r.toppings, ',')::INT[])
  WHERE c.exclusions IS NULL 
    OR NOT (c.exclusions LIKE '%' || t.topping_id::TEXT || '%')
),

extras_toppings AS (
  SELECT c.order_id, t.topping_id, t.topping_name
  FROM customer_orders c
  JOIN pizza_topping t 
    ON c.extras LIKE '%' || t.topping_id::TEXT || '%'
)

SELECT bt.order_id, bt.customer_id, bt.pizza_id, bt.extras, bt.exclusions,
  STRING_AGG(CASE 
      			WHEN et.topping_id IS NOT NULL THEN '2x ' || bt.topping_name
      			ELSE bt.topping_name
    			END, 
    			', ' ORDER BY bt.topping_name
  ) AS ingredient_list
FROM base_toppings bt
LEFT JOIN extras_toppings et
  ON bt.order_id = et.order_id 
  AND bt.topping_id = et.topping_id
GROUP BY bt.order_id, bt.customer_id, bt.pizza_id, bt.extras, bt.exclusions
ORDER BY bt.order_id;

/* Q.23 What is the total quantity of each ingredient used in all delivered pizzas sorted 
	by most frequent first? */

WITH toppings_cte AS ( 
SELECT pizza_id,
    unnest(string_to_array(r.toppings, ','))::INT AS toppings
FROM pizza_recipes r
)

SELECT toppings, t.topping_name, COUNT(toppings) AS qty_ingredient
FROM toppings_cte ct
    JOIN pizza_topping t 
    ON t.topping_id = ct.toppings
    JOIN customer_orders c 
    ON ct.pizza_id = c.pizza_id
    LEFT JOIN runner_orders r 
    ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY toppings, topping_name
ORDER BY qty_ingredient desc;

-- D. Pricing and Ratings
 
/* Q. 24 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
         -- how much money has Pizza Runner made so far if there are no delivery fees? */
		 
WITH price_cte AS 
				( SELECT *, (CASE WHEN pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS price
				 	FROM pizza_names n
					JOIN customer_orders c
					ON n.pizza_id = c.pizza_id
				    JOIN runner_orders r
				  	ON c.order_id = r.order_id
				 	WHERE r.cancellation IS NULL
				  )

SELECT SUM(price) AS revenue
FROM price_cte

-- Q.25 What if there was an additional $1 charge for any pizza extras?

WITH price_cte AS 
				( SELECT *, (CASE WHEN pizza_name = 'Meatlovers' THEN 12 ELSE 10 END + 
							CASE WHEN extras IS NOT NULL THEN 1 ELSE 0 END) AS price
				 	FROM pizza_names n
					JOIN customer_orders c
					ON n.pizza_id = c.pizza_id
				    JOIN runner_orders r
				  	ON c.order_id = r.order_id
				 	WHERE r.cancellation IS NULL
				  )

SELECT SUM(price) AS revenue
FROM price_cte

/* Q.26 The Pizza Runner team now wants to add an additional ratings system that allows customers 
	to rate their runner, how would you design an additional table for this new dataset 
	generate a schema for this new table and insert your own data for ratings for each successful 
	customer order between 1 to 5. */

CREATE TABLE ratings(     --create table schema
	order_id INT,  
	rating INT)
		
WITH rating_cte AS (
				SELECT order_id, 
		  			GENERATESERIES(1, 5) AS rating, 
		  		FROM runner_order
		  		WHERE cancellation IS NULL
			)
		  
INSERT INTO ratings(order_id, rating)
SELECT *
FROM  rating_cte
 
/* Q. 27 Using your newly generated table - 
	can you join all of the information together to form a table which has the following 
	information for successful deliveries?
	customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, 
	Delivery duration, Average speed, Total number of pizzas */

SELECT c.customer_id, c.order_id, r.runner_id, rt.rating,
	c.order_time, r.pickup_time, EXTRACT(MINUTES FROM AGE(r.pickup_time, c.order_time)) AS prep_time, 
	r.duration, ROUND(AVG(r.distance/r.duration), 2) AS avg_speed, COUNT(pizza_id) AS total_pizza
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
JOIN rating rt
ON c.order_id = rt.order_id
GROUP BY c.customer_id, c.order_id, r.runner_id, rt.rating,
			c.order_time, r.duration, r.pickup_time

/* Q.28 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
	and each runner is paid $0.30 per kilometre traveled - 
	how much money does Pizza Runner have left over after these deliveries */

WITH account_cte AS( 
	SELECT r.order_id, c.pizza_id, CASE WHEN pizza_name = 'Meatlovers' THEN 12 ELSE 10 END AS price, 
		   r.distance * 0.30 AS wages
	FROM customer_orders c
	LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
	JOIN pizza_names n
	ON n.pizza_id = c.pizza_id
	WHERE r.cancellation IS NULL
)

SELECT SUM(price- wages) AS sales
FROM account_cte

-- BONUS QUESTIONS

/* If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
 	Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all 
 	the toppings was added to the Pizza Runner menu?*/

/* Impact on existing design:

   	No structural changes needed — the current schema already supports adding new pizza types 
   	and associating any toppings via the pizza_recipes table.

	The only thing required is to add a new entry in pizza_names and 
	corresponding entries in pizza_recipes for the toppings. */

INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');
SELECT * FROM pizza_names;

INSERT INTO pizza_recipes (pizza_id, toppings)
SELECT 3, STRING_AGG(topping_id::TEXT, ', ')
FROM pizza_topping;
SELECT * FROM pizza_recipes;