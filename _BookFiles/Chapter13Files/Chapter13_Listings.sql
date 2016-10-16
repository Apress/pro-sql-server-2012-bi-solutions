/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 13
*******************************************************/

-- Listing 13-1. A Script Header
/******************************************
Title:SalesByTitlesByDates
Description: Which titles were sold on which dates 
Developer:RRoot
Date: 6/1/2012

Change Log: Who, When, What
CMason,6/2/2013,fixed numerous grammatical errors
*******************************************/


-- Listing 13-2. A Basic Starter Query
SELECT 
    OrderNumber
  , OrderDateKey
  , TitleKey
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales


-- Listing 13-3. Adding a Table to the Query
SELECT
    DWPubsSales.dbo.DimTitles.TitleId
  , DWPubsSales.dbo.DimTitles.TitleName   
  , OrderNumber
  , OrderDateKey
  , DWPubsSales.dbo.FactSales.TitleKey
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales 
JOIN DWPubsSales.dbo.DimTitles
  ON DWPubsSales.dbo.FactSales.TitleKey = DWPubsSales.dbo.DimTitles.TitleKey


-- Listing 13-4. Creating Table Aliases with the AS Keyword
SELECT 
    FS.TitleKey
  , DT.TitleName
  , OrderNumber
  , OrderDateKey
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey

-- Listing 13-5. Reordering the Columns and Rows for Better Results
SELECT 
    DT.TitleName
  , DT.TitleId
  , FS.TitleKey
  , OrderNumber
  , OrderDateKey
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
 ON FS.TitleKey = DT.TitleKey
ORDER BY [TitleName], [OrderDateKey]

-- Listing 13-6. Adding Column Aliases for Better Results
SELECT 
    [Title] = DT.TitleName
  , DT.TitleId
  , [Internal Data Warehouse Id] = FS.TitleKey
  , OrderNumber
  , OrderDateKey
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
ORDER BY [Title], [OrderDateKey]

-- Listing 13-7. Adding Data from the DimDates Table
SELECT 
    [Title] = DT.TitleName
  , DT.TitleId
  , [Internal Data Warehouse Id] = FS.TitleKey
  , OrderNumber
  , OrderDateKey
  , [OrderDate] = DD.[Date]
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
ORDER BY [Title], [OrderDate]

-- Listing 13-8. Adding Publisher Names to the Results
SELECT 
    DP.PublisherName
  , [Title] = DT.TitleName
  , DT.TitleId
  , [Internal Data Warehouse Id] = FS.TitleKey
  , OrderNumber
  , OrderDateKey
  , [OrderDate] = DD.[Date]
  , StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey  INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
ORDER BY DP.PublisherName, [Title], [OrderDate]

-- Listing 13-9. Removing Columns Not Needed for Our Query
SELECT 
    DP.PublisherName
  , [Title] = DT.TitleName
  , DT.TitleId
  --, [Internal Data Warehouse Id] = FS.TitleKey
  --, OrderNumber
  --, OrderDateKey
  , [OrderDate] = DD.[Date]
  --, StoreKey
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
ORDER BY DP.PublisherName, [Title], [OrderDate] 



-- Listing 13-10. Using the CONVERT Function 
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
ORDER BY DP.PublisherName, [Title], [OrderDate] 


-- Listing 13-11. Using a WHERE Clause to Filter the Results
SELECT 
    [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = Convert(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
JOIN DWPubsSales.dbo.DimTitles AS DT
   ON FS.TitleKey = DT.TitleKey
JOIN DWPubsSales.dbo.DimDates AS DD
   ON FS.OrderDateKey = DD.DateKey
WHERE [TitleId] = 'PS2091'
ORDER BY [Title], [Date] 


-- Listing 13-12. Using a WHERE Clause to Filter Based on a Given Date
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = Convert(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE [Date] = '09/13/1994'
ORDER BY DP.PublisherName, [Title], [OrderDate]



-- Listing 13-13. Filtering Results Based on Title ID with a Wildcard Symbol
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
   ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
   ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
   ON DT.PublisherKey = DP.PublisherKey
WHERE [TitleId] LIKE 'PS%'   -- % means zero or more characters
ORDER BY DP.PublisherName, [Title], [OrderDate]


-- Listing 13-14. Using the IN Operator
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE [Date] IN ( '09/13/1994' , '05/29/1993' )
ORDER BY DP.PublisherName, [Title], [OrderDate]


-- Listing 13-15. Using the BETWEEN Operator
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE [Date] BETWEEN '09/13/1994' AND '09/14/1994'
ORDER BY DP.PublisherName, [Title], [OrderDate]


-- Listing 13-16. Combining Multiple Operators in a WHERE Statement 
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = Convert(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE 
  [Date] BETWEEN '09/13/1994' AND '09/14/1994'
  AND 
  [TitleId] LIKE 'PS%' 
ORDER BY DP.PublisherName, [Title], [OrderDate]


-- Listing 13-17. Adding Variables to Your Query
DECLARE 
   @StartDate datetime = '09/13/1994'
 , @EndDate datetime = '09/14/1994'
 , @Prefix nVarchar(3) = 'PS%'

SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE 
 [Date] BETWEEN @StartDate AND @EndDate
 AND 
  [TitleId] LIKE @Prefix
ORDER BY DP.PublisherName, [Title], [OrderDate] 

-- Listing 13-18. Adding a Parameter Flag to Show All Data as Needed
DECLARE 
   @ShowAll nVarchar(4) = 'True'
 , @StartDate datetime = '09/13/1994'
 , @EndDate datetime = '09/14/1994'
 , @Prefix nVarchar(3) = 'PS%'
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , SalesQuantity
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE 
 @ShowAll = 'True'
 OR  
 [Date] BETWEEN @StartDate AND @EndDate
 AND 
 [TitleId] LIKE @Prefix
ORDER BY DP.PublisherName, [Title], [OrderDate]



-- Listing 13-19. Adding Aggregate Values to Our Results
DECLARE 
   @ShowAll nVarchar(4) = 'False'
 , @StartDate datetime = '09/13/1994'
 , @EndDate datetime = '09/14/1994'
 , @Prefix nVarchar(3) = 'PS%'
SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , [Total for that Date by Title] = SUM(SalesQuantity)
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE 
 @ShowAll = 'True'
 OR  
 [Date] BETWEEN @StartDate AND @EndDate
 AND 
 [TitleId] LIKE @Prefix
GROUP BY
    DP.PublisherName 
  , DT.TitleName
  , DT.TitleId
  , [Date]
ORDER BY DP.PublisherName, [Title], [OrderDate]


-- Listing 13-20. Fill from Your Querying Parameters with Subqueries
DECLARE 
   @ShowAll nVarchar(4) = 'False'
 , @StartDate datetime = '09/13/1994'
 , @EndDate datetime = '09/14/1994'
 , @Prefix nVarchar(3) = 'PS%'
 , @AverageQty int
    SELECT @AverageQty = Avg(SalesQuantity) FROM DWPubsSales.dbo.FactSales

SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , [Total for that Date by Title] = Sum(SalesQuantity)
  , [Average Qty in the FactSales Table] = @AverageQty
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE 
 @ShowAll = 'True'
 OR  
 [Date] BETWEEN @StartDate AND @EndDate
 AND 
 [TitleId] LIKE @Prefix
GROUP BY
    DP.PublisherName 
  , DT.TitleName
  , DT.TitleId
  , Convert(varchar(50), [Date], 101)
ORDER BY DP.PublisherName, [Title], [OrderDate] 


-- Listing 13-21. Adding KPIs
DECLARE 
   @ShowAll nVarchar(4) = 'True'
 , @StartDate datetime = '09/13/1994'
 , @EndDate datetime = '09/14/1994'
 , @Prefix nVarchar(3) = 'PS%'
 , @AverageQty int
    SELECT @AverageQty = Avg(SalesQuantity) FROM DWPubsSales.dbo.FactSales

SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , [Total for that Date by Title] = Sum(SalesQuantity)
  , [Average Qty in the FactSales Table] = @AverageQty
  , [KPI on Avg Quantity] = CASE
  WHEN Sum(SalesQuantity) 
    between (@AverageQty- 5) and (@AverageQty + 5) THEN 0
  WHEN Sum(SalesQuantity) < (@AverageQty- 5) THEN -1
  WHEN Sum(SalesQuantity) > (@AverageQty + 5) THEN 1
  END
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
WHERE 
 @ShowAll = 'True'
 OR  
 [Date] BETWEEN @StartDate AND @EndDate
 AND 
 [TitleId] LIKE @Prefix
GROUP BY
    DP.PublisherName 
  , DT.TitleName
  , DT.TitleId
  , CONVERT(varchar(50), [Date], 101)
ORDER BY DP.PublisherName, [Title], [OrderDate]


-- Listing 13-22. Creating a View
CREATE VIEW vQuantitiesByTitleAndDate
AS
 --DECLARE 
 --  @ShowAll nVarchar(4) = 'True'
 --, @StartDate nVarchar(10) = '09/13/1994'
 --, @EndDate nVarchar(10) = '09/14/1994'
 --, @Prefix nVarchar(3) = 'PS%'
 --, @AverageQty int
	--SELECT @AverageQty = Avg(SalesQuantity) FROM DWPubsSales.dbo.FactSales

SELECT
    DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , [Total for that Date by Title] = Sum(SalesQuantity)
  --, [Average Qty in the FactSales Table] = @AverageQty
  --, [KPI on Avg Quantity] = CASE
                --WHEN Sum(SalesQuantity) 
                --  between (@AverageQty- 5) and (@AverageQty + 5) THEN 0
                --WHEN Sum(SalesQuantity) < (@AverageQty- 5) THEN -1
                --WHEN Sum(SalesQuantity) > (@AverageQty + 5) THEN 1
                --END
FROM DWPubsSales.dbo.FactSales AS FS 
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
  ON FS.TitleKey = DT.TitleKey
INNER JOIN DWPubsSales.dbo.DimDates AS DD
  ON FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
  ON DT.PublisherKey = DP.PublisherKey
--WHERE 
-- @ShowAll = 'True'
-- OR  
--  [Date] BETWEEN @StartDate AND @EndDate
-- AND 
-- [TitleId] LIKE @Prefix
GROUP BY
    DP.PublisherName 
  , DT.TitleName
  , DT.TitleId
  , CONVERT(varchar(50), [Date], 101)
--ORDER BY DP.PublisherName, [Title], [OrderDate]

-- Listing 13-23. Using Your View Without Filters
SELECT    
    PublisherName 
  , [Title] 
  , [TitleId] 
  , [OrderDate] 
  , [Total for that Date by Title]
 FROM vQuantitiesByTitleAndDate


-- Listing 13-24. Using Your View with the Previous Filters
DECLARE 
   @ShowAll nVarchar(4) = 'False'
 , @StartDate datetime = '09/13/1994'
 , @EndDate datetime = '09/14/1994'
 , @Prefix nVarchar(3) = 'PS%'
 , @AverageQty int
    SELECT @AverageQty = AVG(SalesQuantity) FROM DWPubsSales.dbo.FactSales

SELECT 
    PublisherName 
  , [Title] 
  , [TitleId] 
  , [OrderDate] 
  , [Total for that Date by Title]
  , [Average Qty in the FactSales Table] = @AverageQty
  , [KPI on Avg Quantity] = CASE
                WHEN [Total for that Date by Title] 
                  between (@AverageQty - 5) and (@AverageQty + 5) THEN 0
                WHEN [Total for that Date by Title] < (@AverageQty - 5) THEN -1
                WHEN [Total for that Date by Title] > (@AverageQty + 5) THEN 1
                END
FROM vQuantitiesByTitleAndDate
WHERE 
 @ShowAll = 'True'
 OR  
 [OrderDate] BETWEEN @StartDate AND @EndDate
 AND 
 [TitleId] LIKE @Prefix
ORDER BY PublisherName, [Title], [OrderDate] 

-- Listing 13-25. Creating a Stored Procedure
-- Using Stored Procedures
CREATE PROCEDURE pSelQuantitiesByTitleAndDate
 (
  -- 1) Define the parameter list:
  -- Parameter Name, Data Type, Default Value --
    @ShowAll nVarchar(4) = 'True' -- 'True|False' 
  , @StartDate datetime = '01/01/1990' -- 'Any valid date' 
  , @EndDate datetime = '01/01/2100'  -- 'Any valid date' 
  , @Prefix nVarchar(3) = '%' -- 'Any three wildcard search characters'
  --, @AverageQty int
      --SELECT @AverageQty = Avg(SalesQuantity) FROM DWPubsSales.dbo.FactSales
 )
AS
BEGIN -- the body of the stored procedure --

  -- 2) Set the @AverageQty variable here since you cannot use subqueries in the 
  -- a stored procedures parameter list.
  DECLARE @AverageQty int
    SELECT @AverageQty = Avg(SalesQuantity) FROM DWPubsSales.dbo.FactSales

  --3)  Get the Report Data
  SELECT
  DP.PublisherName 
  , [Title] = DT.TitleName
  , [TitleId] = DT.TitleId
  , [OrderDate] = CONVERT(varchar(50), [Date], 101)
  , [Total for that Date by Title] = SUM(SalesQuantity)
  , [Average Qty in the FactSales Table] = @AverageQty
  , [KPI on Avg Quantity] = CASE
    WHEN Sum(SalesQuantity) 
      BETWEEN (@AverageQty- 5) AND (@AverageQty + 5) THEN 0
    WHEN Sum(SalesQuantity) < (@AverageQty- 5) THEN -1
    WHEN Sum(SalesQuantity) > (@AverageQty + 5) THEN 1
  END
  FROM DWPubsSales.dbo.FactSales AS FS 
  INNER JOIN DWPubsSales.dbo.DimTitles AS DT
    ON FS.TitleKey = DT.TitleKey
  INNER JOIN DWPubsSales.dbo.DimDates AS DD
    ON FS.OrderDateKey = DD.DateKey
  INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
    ON DT.PublisherKey = DP.PublisherKey
  WHERE 
    @ShowAll = 'True'
    OR  
    [Date] BETWEEN @StartDate AND @EndDate
    AND 
    [TitleId] LIKE @Prefix + '%'
  GROUP BY
    DP.PublisherName 
    , DT.TitleName
    , DT.TitleId
    , CONVERT(varchar(50), [Date], 101)
  ORDER BY DP.PublisherName, [Title], [OrderDate] 
END -- the body of the stored procedure --


-- Listing 13-26. Using Your Stored Procedure with Default Values 
EXEC pSelQuantitiesByTitleAndDate


-- Listing 13-27. Using Your Stored Procedue to Set All Values
EXEC pSelQuantitiesByTitleAndDate
   @ShowAll  = 'False'
 , @StartDate = '09/13/1994'
 , @EndDate = '09/14/1994'
 , @Prefix = 'PS'

-- Listing 13-28. Accepting Defaults for Some Parameters 
EXEC pSelQuantitiesByTitleAndDate
   @ShowAll  = 'False'
 , @Prefix = 'PS'


-- Listing 13-29. Adding a Header to Your Stored Procedure
ALTER PROCEDURE pSelQuantitiesByTitleAndDate
 (
  -- 1) Define the parameter list:
  -- Parameter Name, Data Type, Default Value --
    @ShowAll nVarchar(4) = 'True' -- 'True|False' 
  , @StartDate datetime = '01/01/1990' -- 'Any valid date' 
  , @EndDate datetime = '01/01/2100'  -- 'Any valid date' 
  , @Prefix nVarchar(3) = '%' -- 'Any three wildcard search characters'
 )
AS
/****************************************** 
Title:pSelQuantitiesByTitleAndDate
Description: Which titles were sold on which dates 
Developer:RRoot
Date: 9/1/2011

Change Log: Who, When, What
CMason,9/2/2011,fixed even more grammatical errors
*******************************************/
BEGIN -- the body of the stored procedure --
...



