/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 6
*******************************************************/

-- Listing 6-1. Deleting data from the data warehouse tables using the delete command
Delete From dbo.FactSales
Delete From dbo.FactTitlesAuthors
Delete From dbo.DimTitles
Delete From dbo.DimPublishers
Delete From dbo.DimStores
Delete From dbo.DimAuthors


-- Listing 6-2. Truncating the table data and resetting the identity values

/****** Drop Foreign Key s ******/
Alter Table [dbo].[DimTitles]  Drop Constraint [FK_DimTitles_DimPublishers] 
Alter Table [dbo].[FactTitlesAuthors] Drop Constraint [FK_FactTitlesAuthors_DimAuthors] 
Alter Table [dbo].[FactTitlesAuthors] Drop Constraint [FK_FactTitlesAuthors_DimTitles] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimStores] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimTitles] 
Go

/****** Clear all tables and reset their Identity Auto Number ******/
Truncate Table dbo.FactSales
Truncate Table dbo.FactTitlesAuthors
Truncate Table dbo.DimTitles
Truncate Table dbo.DimPublishers
Truncate Table dbo.DimStores
Truncate Table dbo.DimAuthors
Go

/****** Add Foreign Keys ******/
Alter Table [dbo].[DimTitles]  With Check Add Constraint [FK_DimTitles_DimPublishers] 
Foreign Key  ([PublisherKey]) References [dbo].[DimPublishers] ([PublisherKey])

Alter Table [dbo].[FactTitlesAuthors]  With Check Add Constraint [FK_FactTitlesAuthors_DimAuthors] 
Foreign Key  ([AuthorKey]) References [dbo].[DimAuthors] ([AuthorKey])

Alter Table [dbo].[FactTitlesAuthors]  With Check Add Constraint [FK_FactTitlesAuthors_DimTitles] 
Foreign Key ([TitleKey]) References [dbo].[DimTitles] ([TitleKey])

Alter Table [dbo].[FactSales]  With Check Add Constraint [FK_FactSales_DimStores] 
Foreign Key ([StoreKey]) References [dbo].[DimStores] ([Storekey])

Alter Table [dbo].[FactSales]  With Check Add Constraint [FK_FactSales_DimTitles] 
Foreign Key ([TitleKey]) References [dbo].[DimTitles] ([TitleKey])
Go


-- Listing 6-3. Synchronizing Values Between Tables
Use TEMPDB
Go
-- Step #1. Make two demo tables
Create Table Customers
( CustomerId int
, CustomerName varchar(50)
, RowStatus Char(1) check(RowStatus in ('i','u','d') ) )
Go
Create Table DimCustomers
( CustomerId int
, CustomerName varchar(50) )
Go

-- Step #2. Add some starting data
Insert into Customers (CustomerId, CustomerName, RowStatus ) 
Values(1, 'Bob Smith', 'i')
Go
Insert into Customers (CustomerId, CustomerName, RowStatus ) 
Values(2, 'Sue Jones', 'i')
Go
 
-- Step #3. Verify that the tables are not synchronized 
Select * from Customers
Select * from DimCustomers
Go

-- Step #4 Synchronize the tables with this code
BEGIN TRANSACTION
Insert into DimCustomers 
(CustomerId, CustomerName) 
	Select CustomerId, CustomerName
	From Customers
	Where RowStatus is NOT null
	AND RowStatus = 'i'
-- Synchronize Updates
Update DimCustomers
  Set DimCustomers.CustomerName = Customers.CustomerName 
  From DimCustomers
  JOIN Customers
    On  DimCustomers.CustomerId = Customers.CustomerId
    AND RowStatus = 'u'
-- Synchronize Deletes
Delete DimRows
  From DimCustomers as DimRows
  JOIN Customers
    On  DimRows.CustomerId = Customers.CustomerId
    AND RowStatus = 'd'
-- After we import data to the dim table 
-- we must reset the flags to null!
Update Customers Set RowStatus = null
COMMIT TRANSACTION

-- Step #5. Test that both tables now contain the same rows
Select * from Customers
Select * from DimCustomers
Go

-- Step #6. Test the Updates and Delete options
Update Customers 
Set 
  CustomerName = 'Robert Smith'
, RowStatus = 'u'
Where CustomerId = 1
Go
Update Customers 
Set 
  CustomerName = 'deleted'
, RowStatus = 'd'
Where CustomerId = 2
Go
 
-- Step #7. Verify that the tables are not synchronized 
Select * from Customers
Select * from DimCustomers
Go

-- Step #8. Synchronize the tables with the same code as before
BEGIN TRANSACTION
Insert into DimCustomers 
(CustomerId, CustomerName) 
	Select CustomerId, CustomerName
	From Customers
	Where RowStatus is NOT null
	AND RowStatus = 'i'
-- Synchronize Updates
Update DimCustomers
  Set DimCustomers.CustomerName = Customers.CustomerName 
  From DimCustomers
  JOIN Customers
    On  DimCustomers.CustomerId = Customers.CustomerId
    AND RowStatus = 'u'
-- Synchronize Deletes
Delete DimRows
  From DimCustomers as DimRows
  JOIN Customers
    On  DimRows.CustomerId = Customers.CustomerId
    AND RowStatus = 'd'
-- After we import data to the dim table 
-- we must reset the flags to null!
Update Customers Set RowStatus = null
COMMIT TRANSACTION

-- Step #9. Test that both tables contain the same rows
Select * from Customers
Select * from DimCustomers
Go

-- Step #10. Setup an ETL process that will run the Synchronization code

-- Listing 6-4. Selecting all the data from the source table

Select * from [Pubs].[dbo].[Titles] 


-- Listing 6-5. Explicitly listing the columns 
Select 
    [title_id]
  , [title]
  , [type]
  , [pub_id]
  , [price]
  , [advance]
  , [royalty]
  , [ytd_sales]
  , [notes]
  , [pubdate]
From [Pubs].[dbo].[Titles]


-- Listing 6-6. Selecting only data required for the destination table

Select 
    [title_id]
  , [title]
  , [type]
  , [pub_id]
  , [price]
  , [pubdate]
From [Pubs].[dbo].[Titles]



-- Listing 6-7. Using different styles of column aliases

-- Older style column aliases: [column name] as [alias]
Select 
    [title_id] as [TitleId]
  , [title] as [TitleName] 
  , [type] as [TitleType] 
  --, [pub_id]  Will be replaced with a PublisherKey
  , [price] as [TitlePrice] 
  , [pubdate] as [PublishedDate] 
From [Pubs].[dbo].[Titles]

-- Newer style column aliases: [alias] = [column name]
Select 
    [TitleId] = [title_id]
  , [TitleName] = [title]
  , [TitleType] = [type]
  --, [pub_id]  Will be replaced with a PublisherKey
  , [TitlePrice] = [price]
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]


-- Listing 6-8. Using the function to convert data types

Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Cast( [type] as nvarchar(50) )
-- , [pub_id]  Will be replaced with a PublisherKey
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate] -- has the same data type in both tables
From [Pubs].[dbo].[Titles]



-- Listing 6-9. Referencing the natural keys to find the surrogate key value

Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Cast( [type] as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
  On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]



-- Listing 6-10. Inserting values into the DimPublishers table

Insert  Into [DWPubsSales].[dbo].[DimPublishers]
( [PublisherId], [PublisherName] )
Select
  [PublisherId] = Cast( [pub_id] as nchar(4) )
   , [PublisherName] = Cast( [pub_name] as nvarchar(50) )
From [pubs].[dbo].[publishers]


-- Listing 6-11. Conforming values with a select–case statement

Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'					 
      When 'psychology' Then 'Psychology'						 
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     
    End
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]


-- Listing 6-12. Conforming values with a lookup table

-- Create the lookup table
Create table [TitleTypeLookup] ( 
    [TitleTypeKey] int Primary Key Identity 
  , [OriginalTitleType] nvarchar(50)
  , [CleanTitleType] nvarchar(50)
)

-- Add the original and transformed data
Insert into [TitleTypeLookup]
  ( [OriginalTitleType] , [CleanTitleType] ) 
Select 
    [OriginalTitleType] = [Type]	
  , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'					 
      When 'psychology' Then 'Psychology'						 
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     
    End
From [Pubs].[dbo].[Titles]
Group By [Type]	-- get distinct values

-- Combine the data from the lookup table and the original table
Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] =  [CleanTitleType]
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
  On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Join [DWPubsSales].[dbo].[TitleTypeLookup]
  On [Pubs].[dbo].[Titles].[type] =  [DWPubsSales].[dbo].[TitleTypeLookup].[OriginalTitleType]


-- Listing 6-13. Filling the DimDates table
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
  , 'Q' + DateName( quarter, @DateInProcess ) + ' - '
        + Cast( Year(@DateInProcess) as nVarchar(50) ) -- [QuarterName] 
  , Year( @DateInProcess )
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [Year] 
  )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End

Check the table SELECT Top 100 * FROM DimDates


-- Listing 6-14. How nulls work with aggregate functions 

-- Using a null you get the correct answer of 4
Select Avg([Amt]) From ( 
  Select [Amt] = 2
    Union 
  Select [Amt] = 6
    Union 
  Select [Amt] = null 
) as aDemoTableWithNull


-- Using a zero you get the incorrect answer of 2
Select Avg([Amt]) From ( 
  Select [Amt] = 2
    Union 
  Select [Amt] = 6
    Union 
  Select [Amt] = 0 
) as aDemoTableWithZero



-- Listing 6-15. Excluding nulls with the Where clause 

Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Cast( [type] as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Where [Pubs].[dbo].[Titles].[Title_Id] Is Not Null
And [Pubs].[dbo].[Titles].[Title] Is Not Null
And [Pubs].[dbo].[Titles].[Type] Is Not Null
And [Pubs].[dbo].[Titles].[Price] Is Not Null
And [Pubs].[dbo].[Titles].[PubDate] Is Not Null



-- Listing 6-16. Converting null values with the IsNull function 

Select 
    [TitleId] = Cast( isNull( [title_id], -1 ) as nvarchar(6) )
  , [TitleName] = Cast( isNull( [title], 'Unknown' ) as nvarchar(50) )
  , [TitleType] = Cast( isNull( [type], 'Unknown' ) as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( isNull( [price], -1 ) as decimal(18, 4) )
  , [PublishedDate] = isNull( [pubdate], '01/01/1900' ) 
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]



-- Listing 6-17. Adding additional lookup values to the DimDates table 

Set Identity_Insert [DimDates] On
INSERT INTO [DWPubsSales].[dbo].[DimDates] ( 
   [DateKey] -- This is normally added automatically
 , [Date]
 , [DateName]
 , [Month]
 , [MonthName]
 , [Quarter]
 , [QuarterName]
 , [Year]
 , [YearName]
 )
VALUES
 ( -1 -- This will be the Primary key for the first lookup value 
 , '01/01/1900'
 , 'Unknown Day'
 , -1
 , 'Unknown Month'
 , -1
 , 'Unknown Quarter'
 , -1 
 , 'Unknown Year' 
 )
,  -- add a second row
( -2 -- This will be the Primary key for the second lookup value
 , '02/01/1900'
 , 'Corrupt Day'
 , -2
 , 'Corrupt Month'
 , -2
 , 'Corrupt Quarter'
 , -2 
 , 'Corrupt Year' 
 )
Set Identity_Insert [DimDates] Off



-- Listing 6-18. Cross-referencing the DimDates table's dimensional keys 

Select 
    [TitleId] = Cast( isNull( [title_id], -1 ) as nvarchar(6) )
  , [TitleName] = Cast( isNull( [title], 'Unknown' ) as nvarchar(50) )
  , [TitleType] = Cast( isNull( [type], 'Unknown' ) as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( isNull( [price], -1 ) as decimal(18, 4) )
  , [PublishedDateKey] =  isNull( [DWPubsSales].[dbo].[DimDates].[DateKey], -1 )
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Left Join [DWPubsSales].[dbo].[DimDates] -- The "Left" keeps dates not found in DimDates
	On [Pubs].[dbo].[Titles].[pubdate] = [DWPubsSales].[dbo].[DimDates].[Date]


-- Listing 6-19. An example of code that the Query Designer will change without your consent

SELECT au_id AS AuthorId, CAST( (au_fname + N' ' + au_lname)  AS nVarchar(100)) AS AuthorName, state AS AuthorState
FROM  authors

-- Listing 6-20. The ELT Script for DWPubsSales 

/*******************************************************************************
The code in this file is used to create an ETL process for the 
Publication Industries data warehouse.

INPORTANT: You must run the "Creating the Publication Industries Data Warehouse.sql" 
file before you can use this code. This file is in the Chapter05 folder. 
*******************************************************************************/

-- Step 1) Code used to Clear tables (Will be used with SSIS Execute SQL Tasks)
Use DWPubsSales

-- 1a) Drop Foreign Keys 
Alter Table [dbo].[DimTitles] Drop Constraint [FK_DimTitles_DimPublishers] 
Alter Table [dbo].[FactTitlesAuthors] Drop Constraint [FK_FactTitlesAuthors_DimAuthors] 
Alter Table [dbo].[FactTitlesAuthors] Drop Constraint [FK_FactTitlesAuthors_DimTitles] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimStores] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimTitles] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimDates]
Alter Table [dbo].[DimTitles] Drop Constraint [FK_DimTitles_DimDates] 
-- You will add Foreign Keys back (At the End of the ETL Process)
Go

--1b) Clear all tables data warehouse tables and reset their Identity Auto Number 
Truncate Table dbo.FactSales
Truncate Table dbo.FactTitlesAuthors
Truncate Table dbo.DimTitles
Truncate Table dbo.DimPublishers
Truncate Table dbo.DimStores
Truncate Table dbo.DimAuthors
Truncate Table dbo.DimDates
Go

-- Step 2) Code used to fill tables (Will be used with SSIS Data Flow Tasks)

-- 2a) Get source data from pubs.dbo.authors and
-- insert into DimAuthors
Select 
  [AuthorId] = Cast( au_id as nChar(11) )
, [AuthorName] = Cast( (au_fname + ' ' + au_lname) as nVarchar(100) )
, [AuthorState] = Cast( state as nChar(2) )
From pubs.dbo.authors
Go

-- 2b) Get source data from pubs.dbo.stores and
-- insert into DimStores
Select 
  [StoreId] = Cast( stor_id as nChar(4) )
, [StoreName] = Cast( stor_name as nVarchar(50) )
From pubs.dbo.stores
Go

-- 2c) Get source data from pubs.dbo.publishers and
-- insert into DimPublishers
Select 
  [PublisherId] =  Cast( pub_id as nChar(4) )
, [PublisherName] = Cast( pub_name as nVarchar(50) )
From pubs.dbo.publishers
Go

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
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [Year] 
  )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End

-- 2e) Add additional lookup values to DimDates
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

-- 2f) Get source data from pubs.dbo.titles and
-- insert into DimTitles
Select 
    [TitleId] = Cast( isNull( [title_id], -1 ) as nvarchar(6) )
  , [TitleName] = Cast( isNull( [title], 'Unknown' ) as nvarchar(100) )
  , [TitleType] = Cast( isNull( [type], 'Unknown' ) as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( isNull( [price], -1 ) as decimal(18, 4) )
  , [PublishedDateKey] =  isNull(  [DWPubsSales].[dbo].[DimDates].[DateKey], -1)
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Left Join [DWPubsSales].[dbo].[DimDates] -- The "Left" keeps dates not found in DimDates
	On [Pubs].[dbo].[Titles].[pubdate] = [DWPubsSales].[dbo].[DimDates].[Date]
Go

-- 2g) Get source data from pubs.dbo.titleauthor and
-- insert into FactTitlesAuthors
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


-- 2h)Get source data from pubs.dbo.Sales and
-- insert into FactSales
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


-- Step 3) Add Foreign Key s back (Will be used with SSIS Execute SQL Tasks)
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



-- Listing 6-21. Creating a view for ETL processing 
Create View vEtlFactSalesData
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


-- Listing 6-22. Querying the view

Select * from vEtlFactSalesData


-- Listing 6-23. A Select statement with a parameter

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
Where pubs.dbo.sales.ord_date  = @TodaysDate – This will not work in a View!



-- Listing 6-24. Creating a stored procedure for ETL processing 

Create Procedure pEtlFactSalesData
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
Go


-- Listing 6-25. Executing a stored procedure

Execute pEtlFactSalesData


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


-- Listing 6-27. Executing a stored procedure with a parameter

Declare @TodaysDate datetime 
Set @TodaysDate =  Cast( GetDate() as datetime )
Execute pEtlFactSalesData 
  @OrderDate = @TodaysDate


-- Listing 6-28. Creating a User Defined Function 

Create Function fEtlTransformStateToLongName 
  ( @StateAbbreviation nChar(2) )
  Returns nVarchar(50)
As
  Begin 
    Return  
    ( Select Case @StateAbbreviation
        When 'CA' Then 'California'
        When 'OR' Then 'Oregon'    
        When 'WA' Then 'Washington'           
     End )
  End








