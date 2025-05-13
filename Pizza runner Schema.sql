DROP TABLE IF EXISTS runners;
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
	);