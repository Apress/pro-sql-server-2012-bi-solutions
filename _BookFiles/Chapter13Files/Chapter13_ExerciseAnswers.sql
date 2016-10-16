

/************ Exercise 13-1 ************/

--1) Review the data in the FactSales table
--Select * from FactSales
--2) Review the data in the DimStores table
--Select * from DimStores
--3) Review the data in the DimDates table
--Select * FROM DimDates

--4) Combine the data from these table
-- into a report query that returns 
-- store names, store ids, order dates, and the sum quantity  
-- by store and date. 

SELECT 
  DimStores.StoreName
, DimStores.StoreId
, [OrderDate] = Convert(varchar(50), DimDates.Date, 101)
, [Total Qty by Store] = Sum( FactSales.SalesQuantity )
FROM DimDates 
INNER JOIN FactSales 
  ON DimDates.DateKey = FactSales.OrderDateKey
INNER JOIN DimStores 
  ON FactSales.StoreKey = DimStores.Storekey
GROUP BY
  DimStores.StoreName
, DimStores.StoreId
, DimDates.Date
ORDER BY
  DimStores.StoreName
, DimStores.StoreId
, DimDates.Date




/************ Exercise 13-2 ************/

--1) using the code generated and exercise 13-1 create a stored procedure 
-- that allows report users to filter the results based on a range of dates.

CREATE PROCEDURE pSelQuantitiesByStoreAndDate
(
    @StartDate datetime = '01/01/1990' -- 'Any valid date' 
  , @EndDate datetime = '01/01/2100'  -- 'Any valid date' 
 )
AS
/****************************************** 
Title:pSelQuantitiesByStoreAndDate
Description: Qty sold by our stores on which dates 
Developer:RRoot
Date: 1/1/2012

Change Log: Who, When, What
*******************************************/
BEGIN

	SELECT 
	  DimStores.StoreName
	, DimStores.StoreId
	, [OrderDate] = Convert(varchar(50), DimDates.Date, 101)
	, [Total Qty by Store] = Sum( FactSales.SalesQuantity )
	FROM DimDates 
	INNER JOIN FactSales 
	  ON DimDates.DateKey = FactSales.OrderDateKey
	INNER JOIN DimStores 
	  ON FactSales.StoreKey = DimStores.Storekey
	WHERE 
	  DimDates.Date BETWEEN @StartDate AND @EndDate
	GROUP BY
	  DimStores.StoreName
	, DimStores.StoreId
	, DimDates.Date
	ORDER BY
	  DimStores.StoreName
	, DimStores.StoreId
	, DimDates.Date

END
Go


EXEC pSelQuantitiesByStoreAndDate

EXEC pSelQuantitiesByStoreAndDate
   @StartDate = '09/13/1994'
 , @EndDate = '09/14/1994'
    
