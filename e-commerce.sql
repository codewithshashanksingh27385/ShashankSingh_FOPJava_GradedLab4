CREATE TABLE supplier (
    SUPP_ID INT PRIMARY KEY,
    SUPP_NAME VARCHAR(50) NOT NULL,
    SUPP_CITY VARCHAR(50),
    SUPP_PHONE VARCHAR(50) NOT NULL
);
CREATE TABLE customer (
    CUS_ID INT PRIMARY KEY,
    CUS_NAME VARCHAR(20) NOT NULL,
    CUS_PHONE VARCHAR(10) NOT NULL,
    CUS_CITY VARCHAR(30) NOT NULL,
    CUS_GENDER CHAR
);
CREATE TABLE category (
    CAT_ID INT PRIMARY KEY,
    CAT_NAME VARCHAR(20) NOT NULL
);
CREATE TABLE product (
    PRO_ID INT PRIMARY KEY,
    PRO_NAME VARCHAR(20) NOT NULL DEFAULT 'Dummy',
    PRO_DESC VARCHAR(60),
    CAT_ID INT,
    FOREIGN KEY (CAT_ID) REFERENCES category(CAT_ID)
);
CREATE TABLE supplier_pricing (
    PRICING_ID INT PRIMARY KEY,
    PRO_ID INT,
    SUPP_ID INT,
    SUPP_PRICE INT DEFAULT 0,
    FOREIGN KEY (PRO_ID) REFERENCES product(PRO_ID),
    FOREIGN KEY (SUPP_ID) REFERENCES supplier(SUPP_ID)
);
CREATE TABLE order (
    ORD_ID INT PRIMARY KEY,
    ORD_AMOUNT INT NOT NULL,
    ORD_DATE DATE NOT NULL,
    CUS_ID INT,
    PRICING_ID INT,
    FOREIGN KEY (CUS_ID) REFERENCES customer(CUS_ID),
    FOREIGN KEY (PRICING_ID) REFERENCES supplier_pricing(PRICING_ID)
);
CREATE TABLE rating (
    RAT_ID INT PRIMARY KEY,
    ORD_ID INT,
    RAT_RATSTARS INT NOT NULL,
    FOREIGN KEY (ORD_ID) REFERENCES order(ORD_ID)

SELECT CUS_GENDER, COUNT(DISTINCT CUS_ID) AS Total_Customers
FROM customer
JOIN "order" ON customer.CUS_ID = "order".CUS_ID
WHERE ORD_AMOUNT >= 3000
GROUP BY CUS_GENDER;

SELECT "order".ORD_ID, "order".ORD_AMOUNT, "order".ORD_DATE, product.PRO_NAME
FROM "order"
JOIN pricing ON "order".PRICING_ID = pricing.PRICING_ID
JOIN product ON pricing.PRO_ID = product.PRO_ID
WHERE "order".CUS_ID = 2;

SELECT supplier.SUPP_ID, supplier.SUPP_NAME, COUNT(DISTINCT pricing.PRO_ID) AS Total_Products
FROM supplier
JOIN pricing ON supplier.SUPP_ID = pricing.SUPP_ID
GROUP BY supplier.SUPP_ID, supplier.SUPP_NAME
HAVING Total_Products > 1;

SELECT category.CAT_ID, category.CAT_NAME, product.PRO_NAME, MIN(supplier_pricing.SUPP_PRICE) AS Price
FROM category
JOIN product ON category.CAT_ID = product.CAT_ID
JOIN supplier_pricing ON product.PRO_ID = supplier_pricing.PRO_ID
GROUP BY category.CAT_ID, category.CAT_NAME, product.PRO_NAME;

SELECT product.PRO_ID, product.PRO_NAME
FROM product
JOIN pricing ON product.PRO_ID = pricing.PRO_ID
JOIN "order" ON pricing.PRICING_ID = "order".PRICING_ID
WHERE "order".ORD_DATE > '2021-10-05';

SELECT CUS_NAME, CUS_GENDER
FROM customer
WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';

DELIMITER //
CREATE PROCEDURE GetSupplierRatings()
BEGIN
    SELECT supplier.SUPP_ID, supplier.SUPP_NAME, AVG(rating.RAT_RATSTARS) AS Rating,
    CASE
        WHEN AVG(rating.RAT_RATSTARS) = 5 THEN 'Excellent Service'
        WHEN AVG(rating.RAT_RATSTARS) > 4 THEN 'Good Service'
        WHEN AVG(rating.RAT_RATSTARS) > 2 THEN 'Average Service'
        ELSE 'Poor Service'
    END AS Type_of_Service
    FROM supplier
    JOIN supplier_pricing ON supplier.SUPP_ID = supplier_pricing.SUPP_ID
    JOIN pricing ON supplier_pricing.PRICING_ID = pricing.PRICING_ID
    JOIN "order" ON pricing.PRICING_ID = "order".PRICING_ID
    JOIN rating ON "order".ORD_ID = rating.ORD_ID
    GROUP BY supplier.SUPP_ID, supplier.SUPP_NAME;
END //
DELIMITER ;
