-- 1. Dataset Health Check (EDA Foundation)
-- Check row counts & nulls (multi-table)
SELECT 'Customers' AS table_name, COUNT(*) AS total_rows,
       SUM(CASE WHEN CustomerName IS NULL THEN 1 ELSE 0 END) AS null_names
FROM Customers
UNION ALL
SELECT 'Products', COUNT(*), SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END)
FROM Products
UNION ALL
SELECT 'Orders', COUNT(*), SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END)
FROM Orders;



-- 2. Descriptive Statistics (MIN, MAX, AVG, STD)
-- Product price distribution
SELECT
    MIN(Price) AS Min_price,
    MAX(Price) AS Max_price,
    CAST(AVG(Price) AS DECIMAL(10,2)) AS Avg_price,
    ROUND(STDEV(Price), 2) AS Price_SD
FROM Products;



-- 3. Category-wise Distribution (GROUP BY + HAVING)
-- Categories with significant product count
SELECT
    Category,
    COUNT(*) AS Product_Count
FROM Products
GROUP BY Category
HAVING COUNT(*) > 10
ORDER BY product_count DESC;



-- 4. Revenue Contribution Analysis (JOIN + AGG)
-- Revenue by category
SELECT
    p.Category,
    CAST(SUM(p.Price * od.Quantity * (1 - od.Discount)) AS DECIMAL(10,2)) AS Revenue
FROM Order_Details od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY revenue DESC;



-- 5. Percentage Contribution (Window Function)
-- Category % contribution to total revenue
SELECT
    Category,
    revenue,
    CAST(revenue * 100.0 / SUM(revenue) OVER () AS DECIMAL(10,2)) AS Revenue_Percentage
FROM (
    SELECT
        p.Category,
        CAST(SUM(p.Price * od.Quantity * (1 - od.Discount))AS DECIMAL(10,2)) AS Revenue
    FROM Order_Details od
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY p.Category
) t;



-- 6. Customer Purchase Behavior (CTE + JOIN)
-- Average order value per customer
WITH customer_orders AS (
    SELECT
        o.CustomerID,
        o.OrderID,
        SUM(p.Price * od.Quantity * (1 - od.Discount)) AS Order_Value
    FROM Orders o
    JOIN Order_Details od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY o.CustomerID, o.OrderID
)
SELECT
    CustomerID,
    CAST(AVG(order_value)AS DECIMAL(10,2)) AS Avg_Order_Value
FROM customer_orders
GROUP BY CustomerID
ORDER BY avg_order_value DESC;



-- 7. Top-N Analysis (RANK vs DENSE_RANK)
-- Top 5 customers by total spend
SELECT *
FROM (
    SELECT
        c.CustomerName,
        CAST(SUM(p.Price * od.Quantity * (1 - od.Discount)) AS DECIMAL(10,2)) AS Total_Spent,
        RANK() OVER (ORDER BY SUM(p.Price * od.Quantity * (1 - od.Discount)) DESC) AS Rnk
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN Order_Details od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY c.CustomerName
) ranked
WHERE rnk <= 5;



-- 8. Time-Based EDA (DATE FUNCTIONS)
-- Monthly sales trend
SELECT
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month,
    CAST(SUM(p.Price * od.Quantity * (1 - od.Discount))AS DECIMAL(10,2)) AS Revenue
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY year, month;



-- 9. Region Performance Comparison
-- Region-wise average order value
SELECT
    r.RegionName,
    CAST(AVG(t.order_value) AS DECIMAL(10,2)) AS Avg_Order_Value
FROM (
    SELECT
        o.OrderID,
        o.RegionID,
        SUM(p.Price * od.Quantity * (1 - od.Discount)) AS order_value
    FROM Orders o
    JOIN Order_Details od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY o.OrderID, o.RegionID
) t
JOIN Regions r ON t.RegionID = r.RegionID
GROUP BY r.RegionName
ORDER BY Avg_Order_Value DESC;




-- 10. Outlier Detection (EDA Critical)
-- Orders with unusually high value
SELECT *
FROM (
    SELECT
        o.OrderID,
        SUM(p.Price * od.Quantity) AS Order_Value
    FROM Orders o
    JOIN Order_Details od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY o.OrderID
) t
WHERE order_value >
(
    SELECT AVG(order_value) * 3
    FROM (
        SELECT
            SUM(p.Price * od.Quantity) AS Order_Value
        FROM Orders o
        JOIN Order_Details od ON o.OrderID = od.OrderID
        JOIN Products p ON od.ProductID = p.ProductID
        GROUP BY o.OrderID
    ) avg_tbl
);
