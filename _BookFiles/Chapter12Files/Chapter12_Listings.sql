/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 12
*******************************************************/

-- Listing 12-1. An Action Expression Example

"http://www.bing.com/search?q=" + [DimTitles].[Title].CurrentMember.Member_Caption


-- Listing 12-2. A Statement that Filters Data from a Fact Table

SELECT
  FactSales.OrderNumber
, FactSales.OrderDateKey
, FactSales.TitleKey, FactSales.StoreKey
, FactSales.SalesQuantity, DimTitles.TitlePrice AS CurrentStdPrice
 , DimTitles.TitlePrice * FactSales.SalesQuantity AS DerivedTotalPrice
FROM FactSales 
INNER JOIN DimTitles 
  ON FactSales.TitleKey = DimTitles.TitleKey
INNER JOIN DimDates
  ON FactSales.OrderDateKey = DimDates.DateKey
WHERE DimDates.[Year] = 1994

