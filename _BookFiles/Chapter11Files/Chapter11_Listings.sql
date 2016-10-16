/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 11
*******************************************************/

-- Listing 11-1. Validating the Development Report

Use DWPubsSales
Go

Select * 
From DimTitles 
Where TitleName Like 'Computer Phobic %'
-- Results in 14

Select 
TitleKey 
,SalesQuantity = Sum(SalesQuantity) 
,[SalesCount] = Count(*) 
From FactSales 
Where TitleKey = '14'
Group By TitleKey 
-- Results in SalesQuantity = 20 and SalesCount = 1 *Good*

Select 
TitleKey 
,[AuthorCount] = Count(*) 
From FactTitlesAuthors 
Where TitleKey = '14'
Group By TitleKey 
-- Results in AuthorCount = 2 *Good*

-- Listing 11-2. This MDX Expression Produces a Null Value

[DimTitles].[TitlePrice] * [Measures].[SalesQuantity] -- Will be Null due to the context!

-- Listing 11-3. SQL Code for a Derived Measure

SELECT
  FactSales.OrderNumber
, FactSales.OrderDateKey
, FactSales.TitleKey
, FactSales.StoreKey
, FactSales.SalesQuantity
-- Adding derived measures
, DimTitles.TitlePrice as [CurrentStdPrice]
, (DimTitles.TitlePrice * FactSales.SalesQuantity) as DerivedTotalPrice
FROM FactSales 
INNER JOIN DimTitles 
  ON FactSales.TitleKey = DimTitles.TitleKey


-- Listing 11-4. MDX Statement That Groups Values into Three KPI Categories

WITH MEMBER [MyKPI]
AS
case 
 when [SalesQuantity] < 25 or null then -1
 when [SalesQuantity] >= 25 and [SalesQuantity] <= 50 then 0
 when [SalesQuantity] > 50  then 1
end
SELECT 
{ [Measures].[SalesQuantity], [Measures].[MyKPI] } on 0, 
{ [DimTitles].[Title].members } on 1
From[CubeDWPubsSales] 

-- Listing 11-5. Grouping KPI Values into Three Categories

case 
 when [SalesQuantity] < 25 or null then -1
 when [SalesQuantity] >= 25 and [SalesQuantity] <= 50 then 0
 when [SalesQuantity] > 50  then 1
end
