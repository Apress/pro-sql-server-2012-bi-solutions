-- Listing 6-26. Altering the stored procedure to use a parameter 
Alter Procedure pEtlFactSalesData
( @OrderDate datetime )
as
Select 
	  [OrderNumber] = ord_num
	, [OrderDateKey] = DateKey
	, [TitleKey] = DimTitles.TitleKey
	, [StoreKey] = DimStores.StoreKey
	, [SalesQuantity] = qty
From pubs.dbo.sales 
JOIN DWPubsSales.dbo.DimDates
  On pubs.dbo.sales.ord_date = DWPubsSales.dbo.DimDates.date
JOIN  DWPubsSales.dbo.DimTitles
  On pubs.dbo.sales.Title_id = DWPubsSales.dbo.DimTitles.TitleId
JOIN  DWPubsSales.dbo.DimStores
  On pubs.dbo.sales.Stor_id = DWPubsSales.dbo.DimStores.StoreId
Where pubs.dbo.sales.ord_date = @OrderDate
