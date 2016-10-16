/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 8
*******************************************************/

-- Listing 8-1. SQL code from pubs.dbo.authors
Select 
  [AuthorId] = Cast( au_id as nChar(11) )
, [AuthorName] = Cast( (au_fname + ' ' + au_lname) as nVarchar(100) )
, [AuthorState] = Cast( state as nChar(2) )
From pubs.dbo.authors


-- Listing 8-2. SQL code from pubs.dbo.stores
Select 
  [StoreId] = Cast( stor_id as nChar(4) )
, [StoreName] = Cast( stor_name as nVarchar(50) )
From pubs.dbo.stores

-- Listing 8-3. SQL code from pubs.dbo.publishers
Select 
  [PublisherId] =  Cast( pub_id as nChar(4) )
, [PublisherName] = Cast( pub_name as nVarchar(50) )
From pubs.dbo.publishers


-- Listing 8-4. Code that Fills the DimDates table

-- 2d) Create  values for DimDates as needed.
-- Create variables to hold the start and end date
Declare @StartDate datetime = '01/01/1990'
Declare @EndDate datetime = '01/01/1995' 

-- Use a while loop to add dates to the table
Declare @DateInProcess datetime
Set @DateInProcess = @StartDate

While @DateInProcess <= @EndDate
 Begin
 -- Add a row into the date dimension table for this date
 Insert Into DimDates 
 ( [Date], [DateName], [Month], [MonthName], [Quarter], [QuarterName], [Year], [YearName] )
 Values ( 
  @DateInProcess -- [Date]
  , DateName( weekday, @DateInProcess )  -- [DateName]  
  , Month( @DateInProcess ) -- [Month]   
  , DateName( month, @DateInProcess ) -- [MonthName]
  , DateName( quarter, @DateInProcess ) -- [Quarter]
  , 'Q' + DateName( quarter, @DateInProcess ) + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50) ) -- [QuarterName] 
  , Year( @DateInProcess )
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [YearName] 
  )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End

-- Listing 8-5. Code that adds new dates to the DimDates table
Set Identity_Insert [DWPubsSales].[dbo].[DimDates] On
Insert Into [DWPubsSales].[dbo].[DimDates] 
  ( [DateKey]
  , [Date]
  , [DateName]
  , [Month]
  , [MonthName]
  , [Quarter]
  , [QuarterName]
  , [Year], [YearName] )
  Select 
    [DateKey] = -1
  , [Date] =  Cast('01/01/1900' as nVarchar(50) )
  , [DateName] = Cast('Unknown Day' as nVarchar(50) )
  , [Month] = -1
  , [MonthName] = Cast('Unknown Month' as nVarchar(50) )
  , [Quarter] =  -1
  , [QuarterName] = Cast('Unknown Quarter' as nVarchar(50) )
  , [Year] = -1
  , [YearName] = Cast('Unknown Year' as nVarchar(50) )
  Union
  Select 
    [DateKey] = -2
  , [Date] = Cast('01/01/1900' as nVarchar(50) )
  , [DateName] = Cast('Corrupt Day' as nVarchar(50) )
  , [Month] = -2
  , [MonthName] = Cast('Corrupt Month' as nVarchar(50) )
  , [Quarter] =  -2
  , [QuarterName] = Cast('Corrupt Quarter' as nVarchar(50) )
  , [Year] = -2
  , [YearName] = Cast('Corrupt Year' as nVarchar(50) )
  Set Identity_Insert [DWPubsSales].[dbo].[DimDates] Off
  
--  Listing 8-6. SQL code for pubs.dbo.titles
Select 
    [TitleId] = Cast( isNull( [title_id], -1 ) as nvarchar(6) )
  , [TitleName] = Cast( isNull( [title], 'Unknown' ) as nvarchar(50) )
  , [TitleType] = Cast( isNull( [type], 'Unknown' ) as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( isNull( [price], -1 ) as decimal(18, 4) )
  , [PublishedDateKey] =  isNull(  [DWPubsSales].[dbo].[DimDates].[DateKey], -1)
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Left Join [DWPubsSales].[dbo].[DimDates] -- The "Left" keeps dates not found in DimDates
	On [Pubs].[dbo].[Titles].[pubdate] = [DWPubsSales].[dbo].[DimDates].[Date]

-- Listing 8-7. SQL code from pubs.dbo.titleauthor
Select  
  [TitleKey] = DimTitles.TitleKey
--, title_id
, [AuthorKey] = DimAuthors.AuthorKey 
--, au_id
, [AuthorOrder] = au_ord
From pubs.dbo.titleauthor 
JOIN DWPubsSales.dbo.DimTitles
  On pubs.dbo.titleauthor.Title_id = DWPubsSales.dbo.DimTitles.TitleId
JOIN DWPubsSales.dbo.DimAuthors
  On pubs.dbo.titleauthor.Au_id = DWPubsSales.dbo.DimAuthors.AuthorId


-- Listing 8-8. SQL code from pubs.dbo.sales 
Select 
  [OrderNumber] = Cast(ord_num as nVarchar(50))
, [OrderDateKey] = DateKey
--, title_id
, [TitleKey] = DimTitles.TitleKey
--, stor_id
, [StoreKey] = DimStores.StoreKey
, [SalesQuantity] = qty
From pubs.dbo.sales 
JOIN DWPubsSales.dbo.DimDates
  On pubs.dbo.sales.ord_date = DWPubsSales.dbo.DimDates.date
JOIN  DWPubsSales.dbo.DimTitles
  On pubs.dbo.sales.Title_id = DWPubsSales.dbo.DimTitles.TitleId
JOIN  DWPubsSales.dbo.DimStores
  On pubs.dbo.sales.Stor_id = DWPubsSales.dbo.DimStores.StoreId

-- Listing 8-9. Code that adds the Foreign Keys back to the database
-- Step 3) Add Foreign Keys back (Will be used with SSIS Execute SQL Tasks)
Alter Table [dbo].[DimTitles] With Check Add Constraint [FK_DimTitles_DimPublishers] 
Foreign Key ([PublisherKey]) References [dbo].[DimPublishers] ([PublisherKey])

Alter Table [dbo].[FactTitlesAuthors] With Check Add Constraint [FK_FactTitlesAuthors_DimAuthors] 
Foreign Key ([AuthorKey]) References [dbo].[DimAuthors] ([AuthorKey])

Alter Table [dbo].[FactTitlesAuthors] With Check Add Constraint [FK_FactTitlesAuthors_DimTitles] 
Foreign Key ([TitleKey]) References [dbo].[DimTitles] ([TitleKey])

Alter Table [dbo].[FactSales] With Check Add Constraint [FK_FactSales_DimStores] 
Foreign Key ([StoreKey]) References [dbo].[DimStores] ([Storekey])

Alter Table [dbo].[FactSales] With Check Add Constraint [FK_FactSales_DimTitles] 
Foreign Key ([TitleKey]) References [dbo].[DimTitles] ([TitleKey])

Alter Table [dbo].[FactSales]  With Check Add Constraint [FK_FactSales_DimDates] 
Foreign Key ([OrderDateKey]) References [dbo].[DimDates] ([DateKey]) 

Alter Table [dbo].[DimTitles]  With Check Add Constraint [FK_DimTitles_DimDates] 
Foreign Key ([PublishedDateKey]) References [dbo].[DimDates] ([DateKey]) 



-- Listing 8-10. SQL code to verify  DWPubSales table data
Select Top 100 * from dbo.DimAuthors
Select Top 100 * from dbo.DimStores
Select Top 100 * from dbo.DimPublishers
Select Top 100 * from dbo.DimDates
Select Top 100 * from dbo.DimTitles
Select Top 100 * from dbo.FactSales
Select Top 100 * from dbo.FactTitlesAuthors 


















