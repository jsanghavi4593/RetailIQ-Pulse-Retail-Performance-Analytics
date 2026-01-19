-- 1. Null value check
SELECT *
FROM Customers
WHERE CustomerName IS NULL
   OR City IS NULL;


-- 2. Duplicate customers
SELECT CustomerID, COUNT(*) AS Duplicate_Entries
FROM Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;


-- 3. Data consistency (gender)
SELECT DISTINCT Gender FROM Customers;


-- 4. Invalid quantities
SELECT *
FROM Order_Details
WHERE Quantity <= 0;

