-- Validation & Cross-Checking
-- Revenue sanity check
SELECT SUM(Price * Quantity) AS Revenue
FROM Order_Details od
JOIN Products p ON od.ProductID = p.ProductID;

-- Sample-level validation
SELECT *
FROM Order_Details
WHERE OrderID = 10025;
