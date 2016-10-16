
/************ Exercise 13-1 ************/
USE DWNorthwindOrders

-- 1.	Review the data in the QuantityOnOrder table by executing the following SQL code in a query window:
SELECT * from FactOrders

-- 2.	Review the data in the DimCustomers table by executing the following SQL code in a query window:
SELECT * from DimCustomers

-- 3.	Review the data in the DimDates table by executing the following SQL code in a query window:
SELECT * FROM DimDates

-- 4.	Combine the data from these tables into a report query that returns Customer IDs,Customer names, OrderIds,  order dates, and the sum quantity by Customer and date. Your results should look like Figure 13-16.

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
ORDER BY
  DimCustomers.CustomerName
, DimCustomers.CustomerId
, DimDates.Date




/************ Exercise 13-2 ************/

--1) using the code generated and exercise 13-1 create a Customerd procedure 
-- that allows report users to filter the results based on a range of dates.

CREATE -- Drop
PROCEDURE pSelQuantitiesByCustomerAndDate
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
GO

-- 2.	Execute the stored procedure to verify that it works. 
-- (Your results should look like Figure 2.)
EXEC pSelQuantitiesByCustomerAndDate
   @StartDate = '1/1/1998'
 , @EndDate = '1/07/1998'
    
