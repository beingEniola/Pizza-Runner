# Pizza-Runner

### Project Overview
This project showcases my ability to solve business problems by analyzing data from Pizza Runner. In this project, I applied a range of SQL techniques, including aggregate functions, joins, window functions, and CTEs (Common Table Expressions), to analyze and solve business problems.


###  Problem Overview
Pizza Runner, a food delivery service, aim to improve overall efficiency, reduce costs, and increase profitability. They require assistance to clean their data and perform critical analysis to better direct their runners and optimize operations. The key questions to address are:

* Delivery Efficiency: How can we improve delivery times and the speed of our runners?
* Customer Insights: What are the patterns in customer orders, and what are their preferences?
* Ingredient Optimization: How can we optimize the use of ingredients and minimize costs?
* Revenue Analysis: What is the revenue generated, and how much profit is made after delivery costs?


### Project Structure

* Database Setup: I created a database along with all necessary tables, including constraints to ensure data integrity.
* Data Import: Insertion of sample dataset
* Data Cleaning: Handling of empty strings, trimming spaces, and removing inconsistencies. 
* Business Problem Solving: I solved Over 2o business problems.


#### Database Setup

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

Full codes on how I created all the needed table is [here]()

#### Data Import

I inserted the data into the tables 

```sql

```
#### Data Cleaning

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

#### Business Problem. 


	


