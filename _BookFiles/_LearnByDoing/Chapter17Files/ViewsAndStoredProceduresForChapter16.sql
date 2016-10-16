USE DWNorthwindOrders
Go
If Exists( Select Name from SysObjects where name like 'vQuantitiesByCustomerAndDate') 
Begin
 Drop View vQuantitiesByCustomerAndDate
End 
Go
CREATE VIEW vQuantitiesByCustomerAndDate
AS
  SELECT 
    DimCustomers.CustomerId
  , DimCustomers.CustomerName
  , FactOrders.OrderId
  , [OrderDate] = Convert(varchar(50), DimDates.Date, 101)
  , [Total Qty by Customer] = Sum( FactOrders.QuantityOnOrder )
  FROM DimDates 
  INNER JOIN FactOrders
    ON DimDates.DateKey = FactOrders.OrderDateKey
  INNER JOIN DimCustomers 
    ON FactOrders.CustomerKey = DimCustomers.Customerkey
  GROUP BY
    DimCustomers.CustomerId
  , DimCustomers.CustomerName
  , FactOrders.OrderId
  , DimDates.Date
Go

-- Using Stored Procedures
If Exists( Select Name from SysObjects where name like 'pSelQuantitiesByCustomerAndDate') 
Begin
 Drop Procedure pSelQuantitiesByCustomerAndDate
End 
Go
CREATE PROCEDURE pSelQuantitiesByCustomerAndDate
(
    @StartDate datetime = '01/01/1990' -- 'Any valid date' 
  , @EndDate datetime = '01/01/2100'  -- 'Any valid date' 
 )
AS
/****************************************** 
Title:pSelQuantitiesByCustomerAndDate
Description: Qty sold by our Customers on which dates 
Developer:RRoot
Date: 1/1/2012

Change Log: Who, When, What
*******************************************/
BEGIN
  SELECT 
  DimCustomers.CustomerId
, DimCustomers.CustomerName
, FactOrders.OrderId
, [OrderDate] = Convert(varchar(50), DimDates.Date, 101)
, [Total Qty by Customer] = Sum( FactOrders.QuantityOnOrder )
FROM DimDates 
INNER JOIN FactOrders
  ON DimDates.DateKey = FactOrders.OrderDateKey
INNER JOIN DimCustomers 
  ON FactOrders.CustomerKey = DimCustomers.Customerkey
WHERE 
  DimDates.Date BETWEEN @StartDate AND @EndDate
GROUP BY
  DimCustomers.CustomerId
, DimCustomers.CustomerName
, FactOrders.OrderId
, DimDates.Date
ORDER BY
  DimCustomers.CustomerName
, DimCustomers.CustomerId
, DimDates.Date
END
Go
