# Pizza Runner - Sales & Operational Analytics for a Food Delivery Business

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
* Business Problem Solving: I solved Over 20 business problems.

### Database Setup

I created a database for the company and six tables for runners, customer_orders , runner_orders, pizza_names, pizza_recipes and pizza_toppings records.

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

Full codes on how I created all the needed table can be found [here](https://github.com/beingEniola/Pizza-Runner/blob/ccc5622f159a5760a3a9516343ee6033c5861af6/Pizza%20runner%20Schema.sql)

### Data Import

I imported the data into the created tables 

```sql

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
```
This link has my full data importation codes [here](https://github.com/beingEniola/Pizza-Runner/blob/ec4997ab892ae0d84efb6f67fdf111cbb52bc469/pizza%20runner%20data%20import.sql)

### ERD 

I designed an ERD for the database

![pizza runner ERD](https://github.com/user-attachments/assets/f102cd34-8120-4d3c-9362-2af38017c1d9)

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
Full codes on how I cleaned the data can be found [here](https://github.com/beingEniola/Pizza-Runner/blob/main/pizza%20runner%20data%20cleaning.sql) 

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

#### B. Runner and Customer Experience

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
