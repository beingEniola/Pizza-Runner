# Pizza Runner - End-to-End Operational, Sales, and Product Analytics for a Food Delivery Business

## Project Overview
This project showcases my ability to solve business problems by analyzing data from Pizza Runner. In this project, I applied a range of SQL techniques, including aggregate functions, joins, window functions, and CTEs (Common Table Expressions), to analyze and solve business problems.


##  Problem Overview
Pizza Runner, a food delivery service, aim to improve overall efficiency, reduce costs, and increase profitability. They require assistance to clean their data and perform critical analysis to better direct their runners and optimize operations. The key questions to address are:

* How can we improve delivery times and the speed of our runners?
* What are the patterns in customer orders, and what are their preferences?
* How can we optimize the use of ingredients and minimize costs?
* What is the revenue generated, and how much profit is made after delivery costs?


## Project Structure

* Database Setup: I created a database along with all necessary tables, including constraints to ensure data integrity.
* Data Import: Insertion of sample dataset
* Data Cleaning: Handling of empty strings, trimming spaces, and removing inconsistencies. 
* Business Problem Solving: I solved Over 2o business problems.


### Database Setup

I created a database for the company and four tables for runners, customer_orders , runner_orders, pizza_names, pizza_recipes and pizza_toppings records.

```sql
-- create database
CREATE DATABASE pizza_runner;
```

```sql
-- Create runners table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners(
	runner_id INT PRIMARY KEY,
	registration_date DATE
	);
```

Full codes on how I created all the needed table is [here](https://github.com/beingEniola/Pizza-Runner/blob/ccc5622f159a5760a3a9516343ee6033c5861af6/Pizza%20runner%20Schema.sql)

### Data Import

I inserted the data into the tables 

```sql

```
### Data Cleaning

After exploring the imported data, I noticed some inconsistencies which are:

1. Two of the tables contain invalid data. runner_orders and customer_orders tables.
2. The runner_orders table have four columns with empty strings and some with string 'null' values.
3. The distance column in runner_orders stores values as text with the 'km' unit included.
4. The duration column also needs to be cleaned to remove the 'minutes' or 'mins' suffix.
5. Empty strings and 'null' string values in the extras and exclusions columns need to be handled appropriately.
6. I also made sure to change the columns to their appropriate datatypes.


```sql
UPDATE customer_orders
SET 
	exclusions = CASE WHEN exclusions = 'null' THEN NULL
	                 WHEN exclusions = '' THEN NULL
					 ELSE exclusions END,
	extras = CASE WHEN extras = 'null' THEN NULL
	              WHEN extras = '' THEN NULL 
				  ELSE extras END;

```
Full codes on how I cleaned the data is [here](https://github.com/beingEniola/Pizza-Runner/blob/main/pizza%20runner%20data%20cleaning.sql) 

### Analysis. 

In this analysis, I addressed 25 business questions covering the following focus areas:

1. Pizza Metrics: performance and sales trends.
2. Runner and Customer Experience: order fulfillment and delivery efficiency.
3. Ingredient Optimization: pizza compositions, popular extras, exclusions, and total ingredient consumption.
4. Pricing and Ratings: Revenue and profitability analysis

#### A. Pizza Metrics

```sql
--  How many pizzas were ordered? 

SELECT COUNT(order_id) 
FROM customer_orders;
```

| count| 
|------|
| 14 | 

```sql
--  How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, 
	SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meatlovers_orders, 
    SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegeterians_orders
FROM customer_orders 
GROUP BY customer_id
ORDER BY customer_id
```
| customer_id | meatlovers_orders | vegeterians_orders |
|-------------|------------------|-------------------|
| 101         | 2                | 1                 |
| 102         | 2                | 1                 |
| 103         | 3                | 1                 |
| 104         | 3                | 0                 |
| 105         | 0                | 1                 |

#### Runner and Customer Experience

```sql
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? 

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
```
| runner_id | avg_pickup_duration |
|-----------|---------------------|
| 1         | 14                  |
| 2         | 20                  |
| 3         | 10                  |

For the full analysis please click [here](https://github.com/beingEniola/Pizza-Runner/blob/dc802eb614e782b08d162d3b4fa50407902e56f0/pizza%20runner%20analysis.sql)
