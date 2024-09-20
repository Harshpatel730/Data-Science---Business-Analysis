/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
USE orders;

SHOW TABLES;

-- SELECT*
-- FROM orders.online_customer
-- LIMIT 10;

-- DESCRIBE orders.online_customer;

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

SELECT CUSTOMER_ID,
   CASE
      WHEN CUSTOMER_GENDER = 'M' 
      THEN CONCAT('Mr ', upper(CUSTOMER_FNAME), ' ', upper(CUSTOMER_LNAME)) 
      WHEN CUSTOMER_GENDER = 'F' 
      THEN CONCAT('Ms ', upper(CUSTOMER_FNAME), ' ', upper(CUSTOMER_LNAME)) 
   END
   AS full_name, CUSTOMER_EMAIL, Year(CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR, 
   CASE
      WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 
      THEN 'Category A' 
      WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 
      THEN 'Category B' 
      WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 
      THEN 'Category C' 
   END
   AS customer_category 
FROM online_customer
ORDER BY CUSTOMER_ID;

-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 

SELECT
   p.product_id,
   p.product_desc,
   p.product_quantity_avail,
   p.product_price,
   (p.product_quantity_avail * p.product_price) AS inventory_value,
   CASE
      WHEN p.product_price > 20000 
      THEN p.product_price * 0.8 
      WHEN p.product_price BETWEEN 10001 AND 20000
      THEN p.product_price * 0.85 
      ELSE p.product_price * 0.9 
   END
   AS new_price 
FROM PRODUCT AS p 
WHERE p.product_id NOT IN 
   (
      SELECT product_id 
      FROM ORDER_ITEMS
   )
ORDER BY inventory_value DESC;

-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    
SELECT
   pc.product_class_code,
   pc.product_class_desc,
   COUNT(DISTINCT p.product_id) AS product_type_count,
   SUM(p.product_quantity_avail * p.product_price) AS inventory_value 
FROM PRODUCT AS p 
   JOIN PRODUCT_CLASS AS pc 
      ON p.product_class_code = pc.product_class_code 
GROUP BY
   pc.product_class_code,
   pc.product_class_desc 
HAVING SUM(p.product_quantity_avail * p.product_price) > 100000 
ORDER BY inventory_value DESC;

-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

SELECT
   oc.customer_id,
   CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS full_name,
   oc.customer_email,
   oc.customer_phone,
   a.country 
FROM ONLINE_CUSTOMER AS oc 
   JOIN ADDRESS AS a 
      ON oc.address_id = a.address_id 
WHERE oc.customer_id IN 
   (
      SELECT oh.customer_id 
      FROM ORDER_HEADER AS oh 
      WHERE oh.order_status = 'CANCELLED' 
      GROUP BY oh.customer_id 
      HAVING COUNT(DISTINCT oh.order_id) = 
         (
            SELECT COUNT(*) 
            FROM ORDER_HEADER 
            WHERE customer_id = oh.customer_id 
         )
   );
        
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    
SELECT
   SHIPPER.SHIPPER_NAME,
   ADDRESS.CITY,
   COUNT(DISTINCT ONLINE_CUSTOMER.CUSTOMER_ID) AS NUM_CUSTOMERS,
   COUNT(DISTINCT ORDER_HEADER.ORDER_ID) AS NUM_CONSIGNMENTS 
FROM SHIPPER 
   JOIN ORDER_HEADER 
      ON SHIPPER.SHIPPER_ID = ORDER_HEADER.SHIPPER_ID 
   JOIN ONLINE_CUSTOMER 
      ON ORDER_HEADER.CUSTOMER_ID = ONLINE_CUSTOMER.CUSTOMER_ID 
   JOIN ADDRESS 
      ON ONLINE_CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID 
WHERE SHIPPER.SHIPPER_NAME = 'DHL' 
GROUP BY
   SHIPPER.SHIPPER_NAME,
   ADDRESS.CITY;

-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]

SELECT
   oc.customer_id,
   CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS customer_full_name,
   SUM(oi.product_quantity) AS total_quantity,
   SUM(oi.product_quantity * p.product_price) AS total_value 
FROM online_customer AS oc 
   JOIN order_header oh 
      ON oc.customer_id = oh.customer_id 
   JOIN order_items oi 
      ON oh.order_id = oi.order_id 
   JOIN product AS p 
      ON oi.product_id = p.product_id 
WHERE oh.payment_mode = 'Cash' AND oc.customer_lname LIKE 'G%' 
GROUP BY oc.customer_id;
    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
SELECT
   oi.order_id,
   SUM(oi.product_quantity * p.len * p.width * p.height) AS volume 
FROM order_items AS oi 
   JOIN product AS p USING(product_id) 
GROUP BY oi.order_id 
HAVING volume < (
   SELECT c.len * c.width * c.height 
   FROM carton AS c 
   WHERE c.carton_id = 10) 
   ORDER BY volume DESC;

-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)


SELECT
   p.PRODUCT_ID,
   p.PRODUCT_DESC,
   SUM(p.PRODUCT_QUANTITY_AVAIL) AS PRODUCT_QUANTITY_AVAIL,
   SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) AS QUANTITY_SOLD,
   SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) AS AVAILABLE_QUANTITY,
   CASE
      WHEN SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) = 0 
      THEN 'No sales in the past, give discount to reduce inventory' 
      WHEN pc.product_class_desc IN ('Electronics', 'Computer')
      THEN
         CASE
            WHEN (SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0))) < 0.1 * SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) 
            THEN 'Low inventory, need to add inventory' 
            WHEN (SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0))) < 0.5 * SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) 
            THEN 'Medium inventory, need to add some inventory' 
            ELSE 'Sufficient inventory' 
         END
      WHEN pc.product_class_desc IN ('Mobiles', 'Watches')
      THEN
         CASE
            WHEN (SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0))) < 0.2 * SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) 
            THEN 'Low inventory, need to add inventory' 
            WHEN (SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0))) < 0.6 * SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) 
            THEN 'Medium inventory, need to add some inventory' 
            ELSE 'Sufficient inventory' 
         END
      ELSE
         CASE
            WHEN (SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0))) < 0.3 * SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) 
            THEN 'Low inventory, need to add inventory' 
            WHEN (SUM(p.PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(oi.PRODUCT_QUANTITY, 0))) < 0.7 * SUM(IFNULL(oi.PRODUCT_QUANTITY, 0)) 
            THEN 'Medium inventory, need to add some inventory' 
            ELSE 'Sufficient inventory' 
         END
   END
   AS INVENTORY_STATUS 
FROM product AS p 
   LEFT JOIN product_class AS pc 
      ON p.product_class_code = pc.product_class_code 
   LEFT JOIN order_items AS oi 
      ON p.PRODUCT_ID = oi.PRODUCT_ID 
GROUP BY
   p.PRODUCT_ID,
   p.PRODUCT_DESC,
   pc.product_class_desc 
ORDER BY p.PRODUCT_ID ASC;
    
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    
SELECT
   p.PRODUCT_ID,
   p.PRODUCT_DESC,
   SUM(oi.PRODUCT_QUANTITY) AS total_quantity 
FROM ORDER_ITEMS AS oi 
   JOIN PRODUCT AS p 
      ON oi.PRODUCT_ID = p.PRODUCT_ID 
   JOIN ORDER_HEADER AS oh 
      ON oi.ORDER_ID = oh.ORDER_ID 
   JOIN ONLINE_CUSTOMER AS oc 
      ON oh.CUSTOMER_ID = oc.CUSTOMER_ID 
   JOIN ADDRESS AS a 
      ON oc.ADDRESS_ID = a.ADDRESS_ID 
WHERE oi.ORDER_ID IN 
   (
      SELECT oi2.ORDER_ID 
      FROM ORDER_ITEMS AS oi2 
      WHERE oi2.PRODUCT_ID = 201 
   )
   AND a.CITY NOT IN ('Bangalore','New Delhi')
GROUP BY
   p.PRODUCT_ID,
   p.PRODUCT_DESC 
ORDER BY total_quantity DESC;

-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]

SELECT
   oi.order_id,
   oh.customer_id,
   CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS customer_full_name,
   SUM(oi.product_quantity) AS total_quantity_of_products,
   a.pincode 
FROM order_items AS oi 
   INNER JOIN order_header AS oh USING(order_id) 
   INNER JOIN online_customer AS oc USING(customer_id) 
   INNER JOIN address AS a USING(address_id) 
WHERE oh.order_status = 'Shipped' AND a.pincode NOT LIKE "5 % " AND oi.order_id % 2 = 0 
GROUP BY
   oh.customer_id,
   oi.order_id 
ORDER BY oi.order_id;
