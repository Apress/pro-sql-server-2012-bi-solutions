-- Listing 1. Creating the DWNorthwindOrders Data Warehouse Database
USE [master]
GO
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DWNorthwindOrders')
  BEGIN
     -- Close connections to the DWNorthwindOrders database 
    ALTER DATABASE [DWNorthwindOrders] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [DWNorthwindOrders]
  END
GO

CREATE DATABASE [DWNorthwindOrders] ON  PRIMARY 
( NAME = N'DWNorthwindOrders'
, FILENAME = N'C:\_BISolutions\NorthwindFoods\DWNorthwindOrders.mdf' 
, SIZE = 10MB 
, MAXSIZE = 1GB
, FILEGROWTH = 10MB )
 LOG ON 
( NAME = N'DWNorthwindOrders_log'
, FILENAME = N'C:\_BISolutions\NorthwindFoods\DWNorthwindOrders_log.LDF' 
, SIZE = 1MB 
, MAXSIZE = 1GB 
, FILEGROWTH = 10MB)
GO
EXEC [DWNorthwindOrders].dbo.sp_changedbowner @loginame = N'SA', @map = false
GO
ALTER DATABASE [DWNorthwindOrders] SET RECOVERY BULK_LOGGED 
GO


-- Listing 2. Creating the DWNorthwindOrders Tables
USE [DWNorthwindOrders]
GO

/****** Create the Fact Tables ******/
CREATE TABLE [dbo].[FactOrders](
	[OrderID] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[RequiredDateKey] [int] NOT NULL,
	[ShippedDateKey] [int] NOT NULL,
	[PriceOnOrder] [money] NOT NULL,
	[QuantityOnOrder] [int] NOT NULL
	CONSTRAINT [PK_FactOrders] PRIMARY KEY
	(
	[OrderID],
	[CustomerKey],
	[EmployeeKey],
	[ProductKey],
	[OrderDateKey],
	[RequiredDateKey],
	[ShippedDateKey]
	)
) 
GO

/****** Create the Dimension Tables ******/
-- DimCustomers 
CREATE TABLE [dbo].[DimCustomers](
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[CustomerID] [nchar](5) NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[CustomerCity] [nvarchar](50) NOT NULL,
	[CustomerRegion] [nvarchar](50) NOT NULL,
	[CustomerCountry] [nvarchar](50) NOT NULL,
) 
GO

CREATE TABLE [dbo].[DimProducts](
	[ProductKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[ProductCategory] [nvarchar](100) NOT NULL,
	[ProductStdPrice] [decimal](18,4) NOT NULL,
	[ProductIsDiscontinued] [bit] NOT NULL
)
GO

CREATE TABLE [dbo].[DimEmployees](
	[EmployeeKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY, 
	[EmployeeID] [int] NOT NULL,
	[EmployeeName] [nvarchar](100) NOT NULL,
	[ManagerKey] [int] NOT NULL,
	[ManagerID] [int] NOT NULL
)
GO


--Listing 3. Creating the DWNorthwindOrders Foreign Key Constraints
/****** Add Foreign Keys ******/

ALTER TABLE dbo.DimEmployees ADD CONSTRAINT
	FK_DimEmployees_DimEmployees FOREIGN KEY
	(
	[ManagerKey]
	) REFERENCES dbo.DimEmployees
	(
	EmployeeKey
	) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimCustomers FOREIGN KEY
	(CustomerKey) REFERENCES dbo.DimCustomers(CustomerKey) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimEmployees FOREIGN KEY
	(EmployeeKey) REFERENCES dbo.DimEmployees(EmployeeKey) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimProducts FOREIGN KEY
	(ProductKey) REFERENCES dbo.DimProducts(ProductKey) 



-- Listing 4. Creating the DimDates table
CREATE TABLE [dbo].[DimDates](
	[DateKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Date] [datetime] NOT NULL UNIQUE,
	[DateName] [nvarchar](50) NULL,
	[Month] [int] NOT NULL,
	[MonthName] [nvarchar](50) NOT NULL,
	[Quarter] [int] NOT NULL,
	[QuarterName] [nvarchar](50) NOT NULL,
	[Year] [int] NOT NULL,
	[YearName] [nvarchar](50) NOT NULL,
)
GO


-- Listing 5. Creating  more DWNorthwindOrders Foreign Key Constraints

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimDates_OrderDate FOREIGN KEY
	(OrderDateKey) REFERENCES dbo.DimDates([DateKey]) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimDates_RequiredDate FOREIGN KEY
	(RequiredDateKey) REFERENCES dbo.DimDates([DateKey]) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimDates_ShippedDate FOREIGN KEY
	(ShippedDateKey) REFERENCES dbo.DimDates([DateKey]) 
GO

-- Listing 6. Backing Up and Restoring the DWPubsSales Database
/************************************************ 
1) Make a copy of the empty database 
before starting the ETL process
************************************************/

BACKUP DATABASE [DWNorthwindOrders] 
TO  DISK = 
N'C:\_BISolutions\NorthwindFoods\DWNorthwindOrders\DWNorthwindOrders_BeforeETL.bak'
WITH INIT
GO

/************************************************ 
2) Send the file to other team members
and tell them they can restore the database
with this code...
************************************************/

-- Check to see if they already have a database with that name...
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DWNorthwindOrders')
  BEGIN
  -- If they do, they need to close connections to the DWNorthwindOrders database, with this code!
    ALTER DATABASE [DWNorthwindOrders] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  END

-- Now they can restore the empty database...
USE Master 
RESTORE DATABASE [DWNorthwindOrders] 
FROM DISK = 
N'C:\_BISolutions\NorthwindFoods\DWNorthwindOrders\DWNorthwindOrders_BeforeETL.bak'
WITH REPLACE
GO
