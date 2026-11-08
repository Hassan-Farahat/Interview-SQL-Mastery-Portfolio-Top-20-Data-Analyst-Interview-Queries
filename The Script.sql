/*
================================================================================
PORTFOLIO PROJECT: Top 20 Data Analysis Interview SQL Queries
Dialect: Microsoft SQL Server (T-SQL)
Description: A production-ready script featuring well-fitted mock data (Employees, 
Customers, Products, Orders, OrderItems) and the top 20 core SQL queries 
frequently tested in data analyst and business intelligence interviews.
================================================================================
*/

CREATE DATABASE InterviewMastery;
GO
USE InterviewMastery;
GO

-- ============================================================================
-- 1. SETUP SCHEMA & SEED DATA
-- ============================================================================
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    Salary DECIMAL(18,2)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Country VARCHAR(50)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(18,2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATE,
    Status VARCHAR(50),
    TotalAmount DECIMAL(18,2)
);

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(18,2)
);

-- Seed Departments
INSERT INTO Departments VALUES (1, 'Analytics'), (2, 'Sales'), (3, 'Engineering');

-- Seed Employees
INSERT INTO Employees VALUES 
(101, 'Alice Smith', 1, 95000.00),
(102, 'Bob Jones', 1, 85000.00),
(103, 'Charlie Brown', 2, 75000.00),
(104, 'Diana Prince', 2, 95000.00),
(105, 'Evan Wright', 3, 120000.00);

-- Seed Customers
INSERT INTO Customers VALUES 
(1, 'Acme Corp', 'USA'),
(2, 'Globex Inc', 'Canada'),
(3, 'Initech LLC', 'USA'),
(4, 'Stark Industries', 'UK');

-- Seed Products
INSERT INTO Products VALUES 
(501, 'Laptop Pro', 'Electronics', 1200.00),
(502, 'Wireless Mouse', 'Accessories', 25.00),
(503, 'Ergonomic Chair', 'Furniture', 300.00),
(504, 'UltraHD Monitor', 'Electronics', 450.00);

-- Seed Orders
INSERT INTO Orders VALUES 
(1001, 1, '2026-01-10', 'Completed', 1225.00),
(1002, 2, '2026-01-15', 'Completed', 300.00),
(1003, 1, '2026-02-05', 'Completed', 450.00),
(1004, 3, '2026-02-12', 'Pending', 1200.00),
(1005, 4, '2026-03-01', 'Completed', 50.00);

-- Seed OrderItems
INSERT INTO OrderItems VALUES 
(1, 1001, 501, 1, 1200.00),
(2, 1001, 502, 1, 25.00),
(3, 1002, 503, 1, 300.00),
(4, 1003, 504, 1, 4500.00), -- adjusted for illustration
(5, 1004, 501, 1, 1200.00),
(6, 1005, 502, 2, 25.00);
GO

/* 01. Aggregate Metrics: Total Sales by Country */
select table_name from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'base table'
select column_name from INFORMATION_SCHEMA.COLUMNS
where table_name = 'employees'

select distinct country, sum(TotalAmount)
from Customers join Orders on Customers.CustomerID = Orders.CustomerID
group by Country
order by sum(TotalAmount) desc


/* 02. Filtering Groups: HAVING vs WHERE (Find countries with revenue > 500) */

select country, sum(TotalAmount)
from Customers join Orders 
on Customers.CustomerID = Orders.CustomerID
group by Country
having sum(TotalAmount)>500
order by sum(TotalAmount) desc



/* 03. Unmatched Records: Customers with NO orders (LEFT JOIN anti-pattern) */
select CustomerName,COUNT(OrderID)
from Customers left join Orders on Customers.CustomerID=Orders.CustomerID
group by CustomerName
having count(OrderID)=0


/* 04. Subqueries: Find employees earning above the company average salary */
SELECT EmployeeID, EmployeeName, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);

/* 05. Ranking Data: ROW_NUMBER vs RANK vs DENSE_RANK (Salary hierarchy) */
SELECT EmployeeName, Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum,
       RANK() OVER (ORDER BY Salary DESC) AS RankVal,
       DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRankVal
FROM Employees;

/* 06. Top-N per Group: Highest paid employee in each department */
WITH RankedEmployees AS (
    SELECT EmployeeName, DepartmentID, Salary,
           ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS rn
    FROM Employees
)
SELECT EmployeeName, DepartmentID, Salary
FROM RankedEmployees
WHERE rn = 1;


/* 07. Second Highest Salary (Classic Interview Question) */
select max(salary) as SecondHighestSalary
from Employees
where Salary < (select max(salary) from Employees)

/* 08. QUESTION: Generate a pivot-style summary report showing each CustomerID and 
   the count of their 'Completed' versus 'Pending' orders using conditional aggregation. */
   select Customers.CustomerID, 
   sum(case when "Status"='Completed' then 1 else 0 end) as CompletedOrders,
   sum(case when "Status"='pending' then 1 else 0 end) as PendindOrders
   from Customers join Orders 
   on Customers.CustomerID = Orders.CustomerID
   group by Customers.CustomerID

   /* 09. QUESTION: Calculate a cumulative (running) total of revenue across all orders 
   ordered chronologically by OrderDate and OrderID using a window frame. */
   select OrderID, OrderDate, TotalAmount,
   sum(TotalAmount) over (order by orderdate, orderid rows between unbounded preceding and current row)AS RunningTotal
   from orders

   /* 10. QUESTION: Calculate Month-over-Month (MoM) revenue growth percentage. Aggregate 
   revenue by month first, then use the LAG() window function to fetch previous month revenue. */
   WITH MonthlyRevenue AS (
    SELECT DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS SalesMonth,
           SUM(TotalAmount) AS Revenue
    FROM Orders
    GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
    )
    SELECT SalesMonth, Revenue,
       LAG(Revenue) OVER (ORDER BY SalesMonth) AS PrevMonthRevenue,
       (Revenue - LAG(Revenue) OVER (ORDER BY SalesMonth)) * 100.0 / NULLIF(LAG(Revenue) OVER (ORDER BY SalesMonth), 0) AS MoM_Growth_Pct
    FROM MonthlyRevenue;

/* 11. QUESTION: Standardize customer names by converting them to lowercase and removing 
   all spaces to create a clean username handle. */
   select  lower(replace(customername,' ','')) from customers


/* 12. QUESTION: Identify duplicate customer records in the Customers table by grouping 
   by CustomerName and Country, filtering for counts greater than 1 using HAVING. */
   select CustomerName, Country, COUNT(*) as DuplicateCount
   from Customers
   group by CustomerName, Country
   having count(*) >1


/* 13. QUESTION: Write a multi-table join query combining Orders, Customers, Products, 
and OrderItems to list each OrderID, CustomerName, ProductName, Quantity, and UnitPrice. */
SELECT o.OrderID, c.CustomerName, p.ProductName, oi.Quantity, oi.UnitPrice
FROM Orders AS o
JOIN Customers AS c ON o.CustomerID = c.CustomerID
JOIN OrderItems AS oi ON o.OrderID = oi.OrderID
JOIN Products AS p ON oi.ProductID = p.ProductID;

/* 14. QUESTION: Find all customers who have placed at least one order with a total 
   amount greater than 1,000 using the EXISTS operator. */
SELECT CustomerID, CustomerName
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o
    WHERE o.CustomerID = c.CustomerID 
      AND o.TotalAmount > 1000
);


/* 15. QUESTION: Split customer orders into 2 distinct spending tiers (buckets) using 
   the NTILE(2) window function ordered by TotalAmount descending. */
SELECT CustomerID, TotalAmount,
       NTILE(2) OVER (ORDER BY TotalAmount DESC) AS SpendTier
FROM Orders;


/* 16. QUESTION: Calculate a rolling 3-order moving average of the order total amount 
   ordered chronologically by OrderDate and OrderID. */
SELECT OrderID, OrderDate, TotalAmount,
       AVG(CAST(TotalAmount AS DECIMAL(18,2))) OVER (
           ORDER BY OrderDate, OrderID 
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS MovingAvg3Orders
FROM Orders;


/* 17. QUESTION: Categorize products into pricing tiers ('High Tier' for >= 1000, 
   'Mid Tier' for >= 300, else 'Budget Tier') using a CASE statement. */
SELECT ProductName, Price,
       CASE WHEN Price >= 1000 THEN 'High Tier'
            WHEN Price >= 300.00 THEN 'Mid Tier'
            ELSE 'Budget Tier' END AS PriceCategory
FROM Products;


/* 18. QUESTION: Combine customer names and product names into a single list with 
   an entity type tag ('Customer' or 'Product') using UNION ALL. */
SELECT CustomerName AS EntityName, 'Customer' AS EntityType FROM Customers
UNION ALL
SELECT ProductName AS EntityName, 'Product' AS EntityType FROM Products;


/* 19. QUESTION: Calculate the median employee salary across the entire company 
   using the PERCENTILE_CONT(0.5) function. */
SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Salary) OVER () AS MedianSalary
FROM Employees;


/* 20. QUESTION: Find the initial (first) order date for each individual customer 
   using MIN(OrderDate) grouped by CustomerID. */
SELECT CustomerID, MIN(OrderDate) AS FirstOrderDate
FROM Orders
GROUP BY CustomerID;