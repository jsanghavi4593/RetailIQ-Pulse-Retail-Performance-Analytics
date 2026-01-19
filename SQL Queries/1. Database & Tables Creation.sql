CREATE DATABASE RetailIQ;
USE RetailIQ;

CREATE TABLE Regions (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    City VARCHAR(50),
    CreatedAt DATE NOT NULL
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    RegionID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RegionID) REFERENCES Regions(RegionID)
);

CREATE TABLE Order_Details (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
