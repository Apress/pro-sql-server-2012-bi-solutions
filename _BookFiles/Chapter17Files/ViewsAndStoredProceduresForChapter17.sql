USE DWPubsSales
Go
If Exists( Select Name from SysObjects where name like 'vQuantitiesByTitleAndDate') 
Begin
 Drop View vQuantitiesByTitleAndDate
End 
Go
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
  , [OrderDate] = Convert(varchar(50), [Date], 101)
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
  , Convert(varchar(50), [Date], 101)
--ORDER BY DP.PublisherName, [Title], [OrderDate] 

Go

-- Using Stored Procedures
If Exists( Select Name from SysObjects where name like 'pSelQuantitiesByTitleAndDate') 
Begin
 Drop Procedure pSelQuantitiesByTitleAndDate
End 
Go
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
  , [OrderDate] = Convert(varchar(50), [Date], 101)
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
    [TitleName] LIKE @Prefix + '%'
  GROUP BY
    DP.PublisherName 
    , DT.TitleName
    , DT.TitleId
    , Convert(varchar(50), [Date], 101)
  ORDER BY DP.PublisherName, [Title], [OrderDate] 
END -- the body of the stored procedure --
Go


-- New View for Chapter 15
If Exists( Select Name from SysObjects where name like 'vAllTables') 
Begin
 Drop View vAllTables
End 

Go
Create View vAllTables
AS
SELECT 
  DimAuthors.AuthorId
, DimAuthors.AuthorName
, DimAuthors.AuthorState

, DimTitles.TitleId
, DimTitles.TitleName
, DimTitles.TitleType

, FactTitlesAuthors.AuthorOrder

, DimPublishers.PublisherId
, DimPublishers.PublisherName

, DimStores.StoreId
, DimStores.StoreName

, DateName = Convert(Varchar(50), DimDates.[Date], 101)
, DimDates.[MonthName]
, DimDates.[QuarterName]
, DimDates.[YearName]

, FactSales.OrderNumber
, FactSales.OrderDateKey
, FactSales.SalesQuantity
FROM DimAuthors 
INNER JOIN FactTitlesAuthors 
  ON DimAuthors.AuthorKey = FactTitlesAuthors.AuthorKey 
INNER JOIN DimTitles 
  ON FactTitlesAuthors.TitleKey = DimTitles.TitleKey 
INNER JOIN FactSales 
  ON DimTitles.TitleKey = FactSales.TitleKey 
INNER JOIN DimPublishers 
  ON DimTitles.PublisherKey = DimPublishers.PublisherKey 
INNER JOIN DimStores 
  ON FactSales.StoreKey = DimStores.StoreKey 
INNER JOIN DimDates 
  ON FactSales.OrderDateKey = DimDates.DateKey