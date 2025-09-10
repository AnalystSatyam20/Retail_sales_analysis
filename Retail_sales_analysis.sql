--Create Database
CREATE DATABASE Retail_sales;

--Creating Customer_table
CREATE TABLE customers_table
(
CustomerID INT Primary key,
Name VARCHAR(50),
Email VARCHAR(60),
Phone VARCHAR(20),
RegionID INT,
FOREIGN KEY (RegionID) REFERENCES regions_table(RegionID)
);
--Importing customer_table data
COPY table_name(Name,Email,phone,RegionID)
FROM "C:\Users\satya\Downloads\customers_table.csv"
DELIMITER ','
CSV HEADER;

--Creating products_table
CREATE TABLE products_table
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(50),
Category VARCHAR(50),
Price DECIMAL(10,2)
);
--Importing products_table data
COPY table_name(ProductID,ProductName,Category,Price)
FROM "C:\Users\satya\Downloads\products_table.csv"
DELIMITER ','
CSV HEADER;


--Creating regions_table
CREATE TABLE regions_table
(
RegionID INT PRIMARY KEY,
RegionName VARCHAR(50)
);
--Importing regions_table data
COPY table_name(RegionID,RegionName)
FROM "C:\Users\satya\Downloads\regions_table.csv"
DELIMITER ','
CSV HEADER;


--Creating orders_table
CREATE TABLE orders_table
(
OrderID INT PRIMARY KEY,
CustomerID INT,
ProductID INT,
Quantity INT,
OrderDate DATE,


FOREIGN KEY (CustomerID) REFERENCES customers_table(CustomerID),
FOREIGN KEY (productID) REFERENCES products_table(productID)
);
--Importing orders_table data
COPY table_name(OrderID,CustomerID,ProductID,Quantity,OrderDate)
FROM "C:\Users\satya\Downloads\orders_table.csv"
DELIMITER ','
CSV HEADER;


--Creating returns_table
CREATE TABLE returns_table
(
ReturnID INT PRIMARY KEY,
OrderID INT,
ReturnDate DATE,
Reason VARCHAR(40),
FOREIGN KEY (OrderID) REFERENCES orders_table(OrderID)
);

/* Disabling foreign key in returns_table because the OrderID column in
returns table contain some value that are not exist in OrderID column of
Orders_Table */
ALTER TABLE returns_table DISABLE TRIGGER ALL;

--Importing returns_table data
COPY table_name(ReturnID,OrderID,ReturnDate,Reason)
FROM "C:\Users\satya\Downloads\returns_table.csv"
DELIMITER ','
CSV HEADER;

/*Removing values in OrderID column that doesn't existed in OrderID 
column of Orders_table*/
DELETE FROM returns_table
WHERE OrderID NOT IN (SELECT OrderID FROM orders_table);

-- Enable all foreign key triggers on returns_table
ALTER TABLE returns_table ENABLE TRIGGER ALL;

--Creating Duplicate table to perform operations
SELECT * INTO customers from customers_table
SELECT * INTO orders from orders_table
SELECT * INTO products from products_table
SELECT * INTO regions from regions_table
SELECT * INTO returns from returns_table

--Cleaning Data
/*1-- First we will clean customers table data*/

--Checking Null values
WITH Filtered as(
SELECT * FROM customers
)
SELECT 'customerID'
AS Column_name,
COUNT(*) FILTER (WHERE customerID IS NULL) AS Null_Count FROM Filtered
UNION ALL
SELECT 'name',COUNT(*) FILTER(WHERE name is NULL) FROM Filtered
UNION ALL
SELECT 'email',COUNT(*) FILTER(WHERE email is NULL) FROM Filtered
UNION ALL
SELECT 'phone',COUNT(*) FILTER(WHERE phone is NULL) FROM Filtered
UNION ALL
SELECT 'regionid',COUNT(*) FILTER(WHERE regionid is NULL) FROM Filtered

--Treating Null values in email column of customers table
UPDATE customers
set email='Not Available'
WHERE email IS NULL

--Checking Duplicate values in email column
SELECT email from customers
GROUP BY email
HAVING COUNT(*)>1  --Total 843 Duplicate emails found

/*Treating duplicates by Keeping email of minimum customerID and 
removing emailID from other and placing 'Not Avaialable' in them*/
UPDATE customers c
SET email='Not Available'
WHERE c.customerid NOT IN
(
SELECT MIN(customerid)
FROM customers
GROUP BY email
)

--Checking Duplicate values in Phone column
SELECT Phone FROM customers
GROUP BY phone
HAVING COUNT(*)>1

--Treating Duplicate value in phone column
UPDATE customers
SET phone='Not Available'
WHERE phone ='91-XXXX-XXXX'

--Ending of cleaning of Customers table

/*2->Cleaning of products table*/
---Checking Null values in all columns
WITH Filtered as(
SELECT * FROM products
)
SELECT 'productid'
AS Column_name,
COUNT(*) FILTER (WHERE productid IS NULL) AS Null_Count FROM Filtered
UNION ALL
SELECT 'productname',COUNT(*) FILTER(WHERE productname is NULL) FROM Filtered
UNION ALL
SELECT 'category',COUNT(*) FILTER(WHERE category is NULL) FROM Filtered
UNION ALL
SELECT 'price',COUNT(*) FILTER(WHERE price is NULL) FROM Filtered

--Treating Null values in catgeory columns
SELECT * FROM products
where category is null

UPDATE products p
SET category = x.category
FROM products x
WHERE p.productname = x.productname
  AND p.category IS NULL
  AND x.category IS NOT NULL;

--Remaining Null values category is not given so we treat them as unknown
UPDATE products
SET category='Unknown'
WHERE category IS NULL
--Finished Cleaning of products Table

/*3->Cleaning of orders table*/
--Deleting the customerid from Orders that are not present in customers table
DELETE FROM Orders 
WHERE customerid NOT IN (
  SELECT customerid FROM Customers
);

--Deleting the productid from Orders that are not present in products table
DELETE FROM Orders 
WHERE productid NOT IN (
  SELECT productid FROM products
);

--Checking the total negative values in quantity column
SELECT COUNT(*) 
FROM orders 
WHERE quantity < 0;

--Treating negative values in quantity column
UPDATE orders
SET quantity = ABS(quantity)
WHERE quantity < 0;

--Checking the Null values in each column
WITH Filtered as(
SELECT * FROM orders
)
SELECT 'orderid'
AS Column_name,
COUNT(*) FILTER (WHERE orderid IS NULL) AS Null_Count FROM Filtered
UNION ALL
SELECT 'customerid',COUNT(*) FILTER(WHERE customerid is NULL) FROM Filtered
UNION ALL
SELECT 'productid',COUNT(*) FILTER(WHERE productid is NULL) FROM Filtered
UNION ALL
SELECT 'quantity',COUNT(*) FILTER(WHERE quantity is NULL) FROM Filtered
UNION ALL
SELECT 'orderdate',COUNT(*) FILTER(WHERE orderdate is NULL) FROM Filtered


-- Fixing orderdate Null values
WITH first_date AS (
    SELECT 
        customerid,
        MIN(orderdate) AS first_known_date
    FROM orders
    WHERE orderdate IS NOT NULL
    GROUP BY customerid
)
UPDATE orders o
SET orderdate = f.first_known_date
FROM first_date f
WHERE o.customerid = f.customerid
  AND o.orderdate IS NULL;

--Fixing remaining null orderdate values
UPDATE orders
SET orderdate = '1900-01-01'
WHERE orderdate IS NULL;

--Finshed cleaning of orders table

/*4->cleaning of returns table*/
--Deleting orderid from returns table that are not present in orders table
DELETE FROM returns
WHERE orderid NOT IN
(
SELECT orderid from orders
)
SELECT * FROM returns
--Checking Null values
WITH FILTERED AS(
SELECT * FROM returns
)
SELECT 'returnid' 
as column_name,
COUNT(*) FILTER(WHERE returnid is null) AS Null_count
FROM FILTERED
UNION ALL
SELECT 'orderid',COUNT(*) FILTER(WHERE orderid IS NULL) 
FROM FILTERED
UNION ALL
SELECT 'returndate',COUNT(*) FILTER(WHERE returndate IS NULL)
FROM FILTERED
UNION ALL
SELECT 'reason',COUNT(*) FILTER(WHERE reason IS NULL)
FROM FILTERED

/*We have to create a new column return_status as we can't fill 
returndate NULL values because it can lead to misleading report*/
ALTER TABLE returns ADD COLUMN return_status VARCHAR(20);

UPDATE returns
SET return_status = CASE
    WHEN returndate IS NOT NULL THEN 'Returned'
    WHEN reason IS NOT NULL AND returndate IS NULL THEN 'Pending'
    ELSE 'Not Returned'
END;

--Treating Null values of reason column
UPDATE returns
SET reason = 'Not Specified'
WHERE reason IS NULL;
