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

```sql DROP TABLE IF EXISTS runners;
CREATE TABLE runners(
	runner_id INT PRIMARY KEY,
	registration_date DATE
	);
	
DROP TABLE IF EXISTS runner_orders;	
CREATE TABLE runner_orders(
	order_id INT PRIMARY KEY,  
	runner_id INT , --foreign key
	pickup_time VARCHAR(50),
	distance VARCHAR(50),
	duration VARCHAR(50),
	cancellation VARCHAR(50),
	CONSTRAINT fk_runners FOREIGN KEY (runner_id) REFERENCES runners(runner_id));

DROP TABLE IF EXISTS pizza_topping;
CREATE TABLE pizza_topping(
	topping_id INT PRIMARY KEY,
	topping_name VARCHAR(50)
	);
	
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes(
	pizza_id INT PRIMARY KEY,
	toppings TEXT
	);
	
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names(
	pizza_id INT PRIMARY KEY,
	pizza_name VARCHAR(50)
	);

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders(
	order_id INT, -- foreign key
	customer_id INT,
	pizza_id INT, --foreign key
	exclusions TEXT,
	extras TEXT,
	order_time TEXT,
	CONSTRAINT fk_order FOREIGN KEY(order_id) REFERENCES runner_orders(order_id),
	CONSTRAINT fk_pizza FOREIGN KEY(pizza_id) REFERENCES pizza_names(pizza_id),
	CONSTRAINT fk_pizza2 FOREIGN KEY(pizza_id) REFERENCES pizza_recipes(pizza_id)
	); ```
