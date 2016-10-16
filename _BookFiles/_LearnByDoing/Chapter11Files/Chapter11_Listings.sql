-- Listing 1. SQL code to validate products orderd by customers.
SELECT 
  CustomerName  = CompanyName
, ProductName
, Quantity
FROM  Northwind.DBO.Customers 
JOIN Northwind.DBO.Orders 
  ON Customers.CustomerID = Orders.CustomerID
JOIN Northwind.DBO.[Order Details] 
  ON Orders.OrderId = [Order Details].OrderId
JOIN Northwind.DBO.[Products] 
  ON Products.ProductId = [Order Details].ProductId   
WHERE CompanyName = 'Alfreds Futterkiste'
Order By CompanyName, ProductName
