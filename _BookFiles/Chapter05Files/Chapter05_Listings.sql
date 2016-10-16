/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 5
*******************************************************/

-- Listing 5-1. Creating a new database
USE [master]
GO
CREATE DATABASE [DWWeatherTracker] ON  PRIMARY 
( NAME = N'DWWeatherTracker'
, FILENAME = N'D:\_BISolutions\DWWeatherTracker.mdf'  -- On the C:\ hard drive
, SIZE = 10MB 
, MAXSIZE = 1GB
, FILEGROWTH = 10MB )
 LOG ON 
( NAME = N'DWWeatherTracker_log'
, FILENAME = N'F:\_BISolutions\DWWeatherTracker_log.LDF' -- On the D:\ hard drive
, SIZE = 1MB 
, MAXSIZE = 1GB 
, FILEGROWTH = 10MB)
GO
EXEC [DWWeatherTracker].dbo.sp_changedbowner @loginame = N'SA', @map = false
GO
ALTER DATABASE [DWWeatherTracker] SET RECOVERY BULK_ LOGGED 
GO

-- Listing 5-2. Backing up the log file
BACKUP DATABASE [DWWeatherTracker] TO  DISK = N'C:\_BISolutions\DWWeatherTracker.bak'
GO
BACKUP LOG [DWWeatherTracker] TO  DISK = N'C:\_BISolutions\DWWeatherTracker.bak' WITH  INIT


-- Listing 5-3. Shrinking the log file	
USE [DWWeatherTracker]
GO
BACKUP LOG [DWWeatherTracker] TO  DISK = N'C:\_BISolutions\DWWeatherTracker.bak' WITH  INIT
GO
DBCC SHRINKFILE (N'DWWeatherTracker_log' , 0, TRUNCATEONLY)
GO


-- Listing 5-4. Creating tables in a particular filegroup
CREATE TABLE [dbo].[FactWeather]
(	[Date] [datetime] NOT NULL,
	[EventKey] [int] NOT NULL,
	[MaxTempF] [int] NOT NULL,
	[MinTempF] [int] NOT NULL,
 CONSTRAINT [PK_FactWeathers] PRIMARY KEY CLUSTERED  ( [Date] ASC,[EventKey] ASC )
) ON [FactTables]  -- Name of the File Group not the file!


-- Listing 5-5. Creating the DWPubsSales Data Warehouse Database
USE [master]
GO

IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DWPubsSales')
  BEGIN
     -- Close connections to the DWPubsSales database 
    ALTER DATABASE [DWPubsSales] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [DWPubsSales]
  END
GO

CREATE DATABASE [DWPubsSales] ON  PRIMARY 
( NAME = N'DWPubsSales'
, FILENAME = N'C:\_BISolutions\Publications Industries\DWPubsSales.mdf' 
, SIZE = 10MB 
, MAXSIZE = 1GB
, FILEGROWTH = 10MB )
 LOG ON 
( NAME = N'DWPubsSales_log'
, FILENAME = N'C:\_BISolutions\Publications Industries\DWPubsSales_log.LDF' 
, SIZE = 1MB 
, MAXSIZE = 1GB 
, FILEGROWTH = 10MB)
GO
EXEC [DWPubsSales].dbo.sp_changedbowner @loginame = N'SA', @map = false
GO
ALTER DATABASE [DWPubsSales] SET RECOVERY BULK_LOGGED 
GO


--Listing 5-6. Creating the fact table with SQL code
CREATE TABLE [dbo].[FactSales](
	[OrderNumber] [nvarchar](50) NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[TitleKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[SalesQuantity] [int] NOT NULL,
 CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED 
	( [OrderNumber] ASC,[OrderDateKey] ASC, [TitleKey] ASC, [StoreKey] ASC )
)
GO


-- Listing 5-7. Adding foreign key constraints
ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimStores] 
FOREIGN KEY([StoreKey]) REFERENCES [dbo].[DimStores] ([Storekey])
GO

ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimTitles] 
FOREIGN KEY([TitleKey]) REFERENCES [dbo].[DimTitles] ([TitleKey])
GO


-- Listing 5-8. Creating the DWPubsSales tables
USE [DWPubsSales]
GO

/****** Create the Dimension Tables ******/
CREATE TABLE [dbo].[DimStores](
	[StoreKey] [int] NOT NULL PRIMARY KEY Identity,
	[StoreId] [nchar](4) NOT NULL,
	[StoreName] [nvarchar](50) NOT NULL
)
GO

CREATE TABLE [dbo].[DimPublishers](
	[PublisherKey] [int] NOT NULL PRIMARY KEY Identity,
	[PublisherId] [nchar](4) NOT NULL,
	[PublisherName] [nvarchar](50) NOT NULL
) 
GO

CREATE TABLE [dbo].[DimAuthors](
	[AuthorKey] [int] NOT NULL PRIMARY KEY Identity,
	[AuthorId] [nchar](11) NOT NULL,
	[AuthorName] [nvarchar](100) NOT NULL,
	[AuthorState] [nchar](2) NOT NULL
) 
GO

CREATE TABLE [dbo].[DimTitles](
	[TitleKey] [int] NOT NULL PRIMARY KEY Identity,
	[TitleId] [nvarchar](6) NOT NULL,
	[TitleName] [nvarchar](100) NOT NULL,
	[TitleType] [nvarchar](50) NOT NULL,
	[PublisherKey] [int] NOT NULL,
	[TitlePrice] [decimal](18, 4) NOT NULL,
	[PublishedDateKey] [int] NOT NULL
)
GO

/****** Create the Fact Tables ******/
CREATE TABLE [dbo].[FactTitlesAuthors](
	[TitleKey] [int] NOT NULL,
	[AuthorKey] [int] NOT NULL,
	[AuthorOrder] [int] NOT NULL,
 CONSTRAINT [PK_FactTitlesAuthors] PRIMARY KEY CLUSTERED 
	( [TitleKey] ASC, [AuthorKey] ASC )
)
GO

CREATE TABLE [dbo].[FactSales](
	[OrderNumber] [nvarchar](50) NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[TitleKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[SalesQuantity] [int] NOT NULL,
 CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED 
	( [OrderNumber] ASC,[OrderDateKey] ASC, [TitleKey] ASC, [StoreKey] ASC )
)
GO


-- Listing 5-9. Creating the DWPubsSales foreign key constraints
/****** Add Foreign Keys ******/
ALTER TABLE [dbo].[DimTitles]  WITH CHECK ADD  CONSTRAINT [FK_DimTitles_DimPublishers] 
FOREIGN KEY([PublisherKey]) REFERENCES [dbo].[DimPublishers] ([PublisherKey])
GO

ALTER TABLE [dbo].[FactTitlesAuthors]  WITH CHECK ADD  CONSTRAINT [FK_FactTitlesAuthors_DimAuthors] 
FOREIGN KEY([AuthorKey]) REFERENCES [dbo].[DimAuthors] ([AuthorKey])
GO

ALTER TABLE [dbo].[FactTitlesAuthors]  WITH CHECK ADD  CONSTRAINT [FK_FactTitlesAuthors_DimTitles] 
FOREIGN KEY([TitleKey]) REFERENCES [dbo].[DimTitles] ([TitleKey])
GO

ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimStores] 
FOREIGN KEY([StoreKey]) REFERENCES [dbo].[DimStores] ([Storekey])
GO

ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimTitles] 
FOREIGN KEY([TitleKey]) REFERENCES [dbo].[DimTitles] ([TitleKey])
GO

-- Listing 5-10. Creating the DimDates Table
Use DWPubsSales
Go
-- We should create a date dimension table in the database
CREATE TABLE dbo.DimDates (
  [DateKey] int NOT NULL PRIMARY KEY IDENTITY
, [Date] datetime NOT NULL
, [DateName] nVarchar(50)
, [Month] int NOT NULL
, [MonthName] nVarchar(50) NOT NULL
, [Quarter] int NOT NULL
, [QuarterName] nVarchar(50) NOT NULL
, [Year] int NOT NULL
, [YearName] nVarchar(50) NOT NULL
)

-- Listing 5-11. Filling the DimDates Table
-- Since the date table has no associated source table we can fill the data
-- using a SQL script.

-- Create variables to hold the start and end date
DECLARE @StartDate datetime = '01/01/1990'
DECLARE @EndDate datetime = '01/01/1995' 

-- Use a while loop to add dates to the table
DECLARE @DateInProcess datetime
SET @DateInProcess = @StartDate

WHILE @DateInProcess <= @EndDate
 BEGIN
 -- Add a row into the date dimension table for this date
 INSERT INTO DimDates ( 
   [Date]
 , [DateName]
 , [Month]
 , [MonthName]
 , [Quarter]
 , [QuarterName]
 , [Year]
 , [YearName]
 )
 VALUES (  
 -- [Date]
   @DateInProcess 
 -- [DateName]  
 , Convert(nVarchar(50), @DateInProcess, 110) + ', ' + DateName( weekday, @DateInProcess )
 -- [Month]   
 , Month( @DateInProcess )
 -- [MonthName]
 , Cast( Year(@DateInProcess) as nVarchar(4) ) + ' - ' + DateName( month, @DateInProcess )
 -- [Quarter]
 , DateName( quarter, @DateInProcess )
  -- [QuarterName] 
 , Cast( Year(@DateInProcess) as nVarchar(4) )  + ' - ' + 'Q' + DateName( quarter, @DateInProcess )
 -- [Year]
 , Year(@DateInProcess)
 -- [YearName] 
 , Cast( Year(@DateInProcess) as nVarchar(4) )
)  

 -- Add a day and loop again
 SET @DateInProcess = DateAdd(d, 1, @DateInProcess)
 END

-- Check the table SELECT  * FROM DimDates


-- Listing 5-12. Creating the DWPubsSales foreign key constraints
USE [DWPubsSales]
GO

ALTER TABLE [dbo].[FactSales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_DimDates] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDates] ([DateKey])
GO

ALTER TABLE [dbo].[DimTitles]  WITH CHECK ADD  CONSTRAINT [FK_DimTitles_DimDates] FOREIGN KEY([PublishedDateKey])
REFERENCES [dbo].[DimDates] ([DateKey])
GO

-- Listing 5-13. Backing Up and Restoring a Database
BACKUP DATABASE [DWPubsSales] 
TO  DISK = 
N'C:\_BISolutions\PublicationsIndustries\DWPubsSales\DWPubsSales_BeforeETL.bak'
GO

RESTORE DATABASE [DWPubsSales] 
FROM DISK = 
N'C:\_BISolutions\PublicationsIndustries\DWPubsSales\DWPubsSales_BeforeETL.bak'
WITH REPLACE
GO


-- Listing 5-14. Backing Up and Restoring the DWPubsSales Database
/************************************************ 
1) Make a copy of the empty database 
before starting the ETL process
************************************************/

BACKUP DATABASE [DWPubsSales] 
TO  DISK = 
N'C:\_BISolutions\PublicationsIndustries\DWPubsSales\DWPubsSales_BeforeETL.bak'
GO

/************************************************ 
2) Send the file to other team members
and tell them they can restore the database
with this code...
************************************************/

-- Check to see if they already have a copy...
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DWPubsSales')
  BEGIN
  -- If they do, they need to close connections to the DWPubsSales database, with this code!
    ALTER DATABASE [DWPubsSales] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  END

-- Now now restore the Empty database...
USE Master 
RESTORE DATABASE [DWPubsSales] 
FROM DISK = 
N'C:\_BISolutions\PublicationsIndustries\DWPubsSales\DWPubsSales_BeforeETL.bak'
WITH REPLACE
GO