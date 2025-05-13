SELECT * FROM runners; --valid data

SELECT * FROM runner_orders; --dirty column exists

-- clean dirty columns, replace 'null' to null, trim 
UPDATE runner_orders
SET 
  pickup_time = CASE WHEN pickup_time = 'null' THEN NULL ELSE pickup_time END,
  distance = CASE 
               WHEN distance = 'null' THEN NULL
               ELSE REPLACE(distance, 'km', '')
             END,
  duration = CASE 
               WHEN duration = 'null' THEN NULL
               ELSE LEFT(duration, 2)
             END,
  cancellation = CASE WHEN cancellation = 'null' THEN NULL 
  					  WHEN cancellation = '' THEN NULL 
					  ELSE cancellation END;
  
-- change datatype
ALTER TABLE runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::TIMESTAMP;

ALTER TABLE runner_orders
ALTER COLUMN distance TYPE NUMERIC USING distance::NUMERIC;

ALTER TABLE runner_orders
ALTER COLUMN duration TYPE INT USING duration::INT;

SELECT * FROM pizza_names; --valid data

SELECT * FROM pizza_recipes; --valid data

SELECT * FROM pizza_topping; --valid data


SELECT * FROM customer_orders; -- needs cleaning

-- change null to Null

UPDATE customer_orders
SET 
	exclusions = CASE WHEN exclusions = 'null' THEN NULL
	                 WHEN exclusions = '' THEN NULL
					 ELSE exclusions END,
	extras = CASE WHEN extras = 'null' THEN NULL
	              WHEN extras = '' THEN NULL 
				  ELSE extras END;
	
ALTER TABLE customer_orders
ALTER COLUMN order_time TYPE TIMESTAMP USING order_time::TIMESTAMP;

