-- Create the Region table
CREATE TABLE Region (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(255) UNIQUE
);

-- Create the Country table
CREATE TABLE Country (
    country_id SERIAL PRIMARY KEY,
    region_id INTEGER REFERENCES Region(region_id),
    country_name VARCHAR(255) UNIQUE
);

-- Create the State table
CREATE TABLE State (
    state_id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES Country(country_id),
    state_name VARCHAR(255) UNIQUE
);

-- Create the City table
CREATE TABLE City (
    city_id SERIAL PRIMARY KEY,
    state_id INTEGER REFERENCES State(state_id),
    city_name VARCHAR(255) UNIQUE
);

-- Create the Warehouse table
CREATE TABLE Warehouse (
    warehouse_id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES City(city_id),
    warehouse_address VARCHAR(255),
    warehouse_name VARCHAR(255),
	postal_code VARCHAR(20)
);

-- Create the Employee table
CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    warehouse_id INTEGER REFERENCES Warehouse(warehouse_id),
    employee_name VARCHAR(255),
    employee_email VARCHAR(255) UNIQUE,
    employee_phone VARCHAR(20),
    employee_hire_date DATE,
    employee_job_title VARCHAR(100)
);

-- Create the Category table
CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE
);

-- Create the Product table
CREATE TABLE Product (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES Category(category_id),
    product_name VARCHAR(255),
    product_description VARCHAR(255),
    product_standard_cost NUMERIC,
    product_list_price NUMERIC,
    profit NUMERIC
);

-- Create the Customer table
CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_address VARCHAR(255),
    customer_credit_limit NUMERIC,
    customer_email VARCHAR(255) UNIQUE,
    customer_phone VARCHAR(20)
);

-- Create the Order table
CREATE TABLE OrderTable (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES Customer(customer_id),
    order_date DATE
);

-- Create the Order Item table
CREATE TABLE OrderItem (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES OrderTable(order_id),
    product_id INTEGER REFERENCES Product(product_id),
    order_item_quantity INTEGER,
    per_unit_price NUMERIC,
    total_item_quantity INTEGER,
    product_shipping_status VARCHAR(100)
);

--Create staging table for data import
CREATE TABLE staging_inventory (
    "RegionName" TEXT,
    "CountryName" TEXT,
    "State" TEXT,
    "City" TEXT,
    "PostalCode" TEXT,
    "WarehouseAddress" TEXT,
    "WarehouseName" TEXT,
    "EmployeeName" TEXT,
    "EmployeeEmail" TEXT,
    "EmployeePhone" TEXT,
    "EmployeeHireDate" DATE,
    "EmployeeJobTitle" TEXT,
    "CategoryName" TEXT,
    "ProductName" TEXT,
    "ProductDescription" TEXT,
    "ProductStandardCost" NUMERIC,
    "Profit" NUMERIC,
    "ProductListPrice" NUMERIC,
    "CustomerName" TEXT,
    "CustomerAddress" TEXT,
    "CustomerCreditLimit" NUMERIC,
    "CustomerEmail" TEXT,
    "CustomerPhone" TEXT,
    "Status" TEXT,
    "OrderDate" DATE,
    "OrderItemQuantity" INTEGER,
    "PerUnitPrice" NUMERIC,
    "TotalItemQuantity" INTEGER
);

DROP TABLE staging_inventory;

--load data into staging table


--inserting data 

INSERT INTO Region (region_name)
SELECT DISTINCT "RegionName" 
FROM staging_inventory;

INSERT INTO Country (country_name, region_id)
SELECT DISTINCT si."CountryName", r.region_id
FROM staging_inventory AS si 
LEFT JOIN Region AS r 
	ON si."RegionName" = r.region_name
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO State (state_name, country_id)
SELECT DISTINCT si."State", c.country_id
FROM staging_inventory AS si
JOIN Country AS c 
	ON si."CountryName" = c.country_name;

INSERT INTO City (city_name, state_id)
SELECT DISTINCT si."City", s.state_id
FROM staging_inventory AS si
JOIN state AS s 
	ON si."State" = s.state_name;

INSERT INTO Warehouse (city_id, warehouse_address, warehouse_name, postal_code)
SELECT 
	ci.city_id, 
	si."WarehouseAddress", 
	si."WarehouseName", 
	si."PostalCode"
FROM staging_inventory AS si
JOIN city AS ci 
	ON si."City" = ci.city_name;

INSERT INTO Employee (employee_email, warehouse_id, employee_name, employee_phone, employee_hire_date, employee_job_title)
SELECT 
	DISTINCT si."EmployeeEmail",
	w.warehouse_id, 
	si."EmployeeName", 
	si."EmployeePhone", 
	si."EmployeeHireDate"::DATE, 
	si."EmployeeJobTitle"
FROM staging_inventory AS si
JOIN Warehouse AS w 
	ON si."WarehouseName" = w.warehouse_name
ON CONFLICT (employee_email) DO NOTHING;

INSERT INTO Category (category_name)
SELECT DISTINCT "CategoryName" 
FROM staging_inventory;

INSERT INTO Product (category_id, product_name, product_description, product_standard_cost, product_list_price, profit)
SELECT
    c.category_id,
    si."ProductName",
    si."ProductDescription",
    si."ProductStandardCost",
    si."ProductListPrice",
    si."Profit"
FROM staging_inventory AS si
JOIN Category AS c 
	ON si."CategoryName" = c.category_name;

INSERT INTO Customer (customer_email, customer_name, customer_address, customer_credit_limit, customer_phone)
SELECT 
	DISTINCT si."CustomerEmail",
	si."CustomerName",
    si."CustomerAddress",
    si."CustomerCreditLimit",
    si."CustomerPhone"
FROM staging_inventory AS si;

INSERT INTO OrderTable (customer_id, order_date)
SELECT 
	c.customer_id,
    si."OrderDate"::DATE
FROM staging_inventory AS si
JOIN Customer AS c 
	ON si."CustomerName" = c.customer_name;

INSERT INTO OrderItem (order_id, product_id, order_item_quantity, per_unit_price, total_item_quantity, product_shipping_status)
SELECT
    o.order_id,
    p.product_id,
    si."OrderItemQuantity",
    si."PerUnitPrice",
    si."TotalItemQuantity",
    si."Status"
FROM staging_inventory si
JOIN OrderTable AS o 
	ON si."OrderDate" = o.order_date 
		AND si."CustomerName" = (
			SELECT customer_name 
			FROM customer 
			WHERE customer_id = o.customer_id)
JOIN product AS p 
	ON si."ProductName" = p.product_name;

--check tables
SELECT *
FROM product;

--check order sequence for id columns
SELECT sequence_name
FROM information_schema.sequences;

ALTER SEQUENCE region_region_id_seq RESTART WITH 1;
ALTER SEQUENCE country_country_id_seq RESTART WITH 1;
ALTER SEQUENCE state_state_id_seq RESTART WITH 1;
ALTER SEQUENCE warehouse_warehouse_id_seq RESTART WITH 1;
ALTER SEQUENCE city_city_id_seq RESTART WITH 1;
ALTER SEQUENCE employee_employee_id_seq RESTART WITH 1;
ALTER SEQUENCE category_category_id_seq RESTART WITH 1;
ALTER SEQUENCE product_product_id_seq RESTART WITH 1;
ALTER SEQUENCE customer_customer_id_seq RESTART WITH 1;
ALTER SEQUENCE ordertable_order_id_seq RESTART WITH 1;
ALTER SEQUENCE orderitem_order_item_id_seq RESTART WITH 1;

--fix issue with employee name and employee email 97: unexpected 'ya at end
--why do products of category 5 (storage) have no profit?

--link employee table to order table
ALTER TABLE ordertable
ADD COLUMN employee_id INT;

UPDATE ordertable AS o
SET employee_id = emp_data.employee_id
FROM (
    SELECT DISTINCT si."EmployeeEmail", e.employee_id, si."OrderDate"
    FROM staging_inventory AS si
    JOIN employee AS e 
		ON si."EmployeeEmail" = e.employee_email
) AS emp_data
WHERE o.order_date = emp_data."OrderDate"
	AND o.employee_id IS NULL;  -- Only update orders where the employee_id is not yet set


-- Create a temporary table to hold order analysis data
CREATE TEMP TABLE order_analysis AS
SELECT 
    product_id,
    AVG(order_item_quantity) AS avg_order_quantity,
    MAX(order_item_quantity) AS max_order_quantity,
    COUNT(order_id) AS order_count
FROM OrderItem
GROUP BY product_id;

-- View the analysis results
SELECT * FROM order_analysis;

--create the Inventory table
CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Product(product_id),
    stock_level INT,
    reorder_threshold INT
);

--start inventory_id sequence from 1
ALTER SEQUENCE inventory_inventory_id_seq RESTART WITH 1;

--Insert estimated initial stock levels and reorder thresholds into the Inventory table
INSERT INTO Inventory (product_id, stock_level, reorder_threshold)
SELECT 
    product_id,
    GREATEST(2 * max_order_quantity, 50) AS stock_level,  -- Stock level is twice the max order quantity or a default of 50
    LEAST(0.3 * GREATEST(2 * max_order_quantity, 50), 20) AS reorder_threshold  -- Reorder threshold is 30% of stock level, max 20
FROM order_analysis;

UPDATE Inventory
SET reorder_threshold = CASE
    WHEN stock_level > 100 THEN ROUND(0.2 * stock_level)  -- Use 20% if stock level is high
    WHEN stock_level <= 20 THEN 5  -- Set a minimum threshold for low-stock items
    ELSE ROUND(0.3 * stock_level)  -- Default to 30% for other cases
END;

SELECT * FROM Inventory;

--trigger function to update inventory
CREATE OR REPLACE FUNCTION update_inventory_after_sale()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the inventory stock level
    UPDATE Inventory
    SET stock_level = stock_level - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_order_item_insert
AFTER INSERT ON OrderItem
FOR EACH ROW
EXECUTE FUNCTION update_inventory_after_sale();


-- Create a table to store reorder requests
CREATE TABLE ReorderRequests (
    reorder_request_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Product(product_id),
    reorder_quantity INT,
    request_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'Pending'
);

ALTER SEQUENCE reorderrequests_reorder_request_id_seq RESTART WITH 1;

-- Create or replace the procedure to reorder products when stock falls below a threshold
CREATE OR REPLACE PROCEDURE reorder_products()
LANGUAGE plpgsql
AS $$
DECLARE
    inventory_item RECORD;
    reorder_qty INT;
BEGIN
    -- Loop through each product in the Inventory table
    FOR inventory_item IN 
        SELECT product_id, stock_level, reorder_threshold 
        FROM Inventory 
    LOOP
        -- Check if the stock level is below the reorder threshold
        IF inventory_item.stock_level < inventory_item.reorder_threshold THEN
            -- Calculate reorder quantity, for example, to reach twice the threshold level
            reorder_qty := inventory_item.reorder_threshold * 2;

            -- Insert a new reorder request into the ReorderRequests table
            INSERT INTO ReorderRequests (product_id, reorder_quantity)
            VALUES (inventory_item.product_id, reorder_qty);

            -- Output message (for logging or debugging)
            RAISE NOTICE 'Reorder request created for Product ID %, Quantity: %', 
                         inventory_item.product_id, reorder_qty;
        END IF;
    END LOOP;
END;
$$;

-- Call the reorder_products procedure to create reorder requests
CALL reorder_products();

-- Populate the ReorderRequests table with existing inventory data
INSERT INTO ReorderRequests (product_id, reorder_quantity, request_date, status)
SELECT
    i.product_id,
    -- Calculate reorder quantity, for example, to reach twice the reorder threshold level
    i.reorder_threshold * 2 AS reorder_quantity,
    CURRENT_DATE AS request_date,  -- Set the request date to today
    'Pending' AS status  -- Set the status to 'Pending'
FROM
    Inventory AS i
WHERE
    i.stock_level < i.reorder_threshold;  -- Only insert if stock is below the threshold


-- Check the ReorderRequests table to see if the requests were created
SELECT * FROM ReorderRequests;

