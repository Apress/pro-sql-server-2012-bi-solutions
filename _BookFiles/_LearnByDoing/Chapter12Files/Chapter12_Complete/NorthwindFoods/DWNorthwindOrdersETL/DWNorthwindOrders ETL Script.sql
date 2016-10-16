-- Step 1) Code used to Clear tables -- 
--*********************************--
Use DWNorthwindOrders
-- 1a) Drop Foreign Keys 
-- Used with Execute SQL Task "Drop Foreign Key Constraints"
Alter Table [dbo].DimEmployees Drop Constraint FK_DimEmployees_DimEmployees
Alter Table [dbo].FactOrders Drop Constraint FK_FactOrders_DimCustomers
Alter Table [dbo].FactOrders Drop Constraint FK_FactOrders_DimEmployees
Alter Table [dbo].FactOrders Drop Constraint FK_FactOrders_DimProducts
Alter Table [dbo]. FactOrders Drop Constraint FK_FactOrders_DimDates_OrderDate 
Alter Table [dbo].FactOrders Drop Constraint FK_FactOrders_DimDates_RequiredDate
Alter Table [dbo].FactOrders Drop Constraint FK_FactOrders_DimDates_ShippedDate
-- You will add Foreign Keys back (At the End of the ETL Process)
Go

--1b) Clear all tables data warehouse tables and reset their Identity Auto Number 
-- Used with Execute SQL Task "Clear All Tables"
Truncate Table dbo.[FactOrders]
Truncate Table dbo.[DimCustomers]
Truncate Table dbo.[DimProducts]
Truncate Table dbo.[DimEmployees]
Truncate Table dbo.[DimDates]
Go

-- Step 2) Code used to fill tables --
--*********************************--
-- 2a) Get source data from Northwind.dbo.Customers 
-- Used with Data Flow Task "Fill DimCustomers"
Select 
    CustomerID = CustomerID
  , CustomerName = Cast( CompanyName as nVarchar(100) )
  , CustomerCity = Cast( City as nVarchar(50) )
  , CustomerRegion = Cast( IsNull(Region, Country) as nVarchar(50) )
  , CustomerCountry = Cast( Country as nVarchar(50) )
From Northwind.dbo.Customers
Go

-- 2b) Get source data from Northwind.dbo.Employees 
-- Used with Execute Task "Fill DimEmployees"
    -- Step 2b-1: Import data and get Surrogate Key values
    INSERT INTO DimEmployees
    (EmployeeID, EmployeeName, ManagerKey, ManagerID)
	    SELECT 
	     [EmployeeID]
	    ,[EmployeeName] = Cast([FirstName] + ' ' + [LastName] as nVarchar(100))
	    ,[ManagerKey] = IsNull([ReportsTo], [EmployeeID]) 
	    ,[ManagerID] = IsNull([ReportsTo], [EmployeeID]) 
	    FROM [Northwind].[dbo].[Employees]
    
    -- Step 2b-2: Get Surrogate values for the ManagerKeys
    Select Mgr.* , Emp.EmployeeKey as NewMgrKey
    Into #EmpTemp
    FROM dbo.DimEmployees as Emp
    JOIN  dbo.DimEmployees as Mgr
	    On Emp.EmployeeId = Mgr.ManagerKey

    -- Step 2b-3: Update the table with Surrogate Key values
    UPDATE DimEmployees
    Set DimEmployees.[ManagerKey] =  #EmpTemp.NewMgrKey
    FROM DimEmployees
    JOIN #EmpTemp 
    On  DimEmployees.[ManagerKey] = #EmpTemp.[ManagerKey]
    -- Step 2b-4: Drop the Temp Table
    Drop Table #EmpTemp
Go

-- 2c) Get source data from Northwind.dbo.Products and Categories
-- Used with Data Flow Task "Fill DimProducts"
Select 
  ProductID = ProductId
, ProductName = Cast( ProductName as nVarchar(100) )
, ProductCategory = Cast( CategoryName as nVarchar(100) )
, ProductStdPrice =  Cast( UnitPrice as Decimal(18,4) )
, ProductIsDiscontinued = Cast( (Case When Discontinued  = 1 Then 'T' Else 'F' End ) as nChar(1))
From Northwind.dbo.Products as P
Join Northwind.dbo.Categories as C
  On P.CategoryId  = C.CategoryId
Go

-- 2d) Create values for DimDates.
-- Used with Execute SQL Task "Fill DimDates"
-- Create variables to hold the start and end date
Declare @StartDate datetime = '01/01/1995'
Declare @EndDate datetime = '01/01/2000' 

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
  , DateName( weekday, @DateInProcess ) + ', ' + Cast(@DateInProcess as nVarchar(20)) -- [DateName]  
  , Month( @DateInProcess ) -- [Month]   
  , DateName( month, @DateInProcess ) -- [MonthName]
  , DateName( quarter, @DateInProcess ) -- [Quarter]
  , 'Q' + DateName( quarter, @DateInProcess ) + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50) ) -- [QuarterName] 
  , Year( @DateInProcess ) -- [Year] 
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [YearName] 
  )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End

-- 2e) Add additional lookup values to DimDates
-- Used with Execute SQL Task "Add Null Date Lookup Values"
Set Identity_Insert [DWNorthwindOrders].[dbo].[DimDates] On
Insert Into [DWNorthwindOrders].[dbo].[DimDates] 
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
  , [Date] = Cast('01/02/1900' as nVarchar(50) )
  , [DateName] = Cast('Corrupt Day' as nVarchar(50) )
  , [Month] = -2
  , [MonthName] = Cast('Corrupt Month' as nVarchar(50) )
  , [Quarter] =  -2
  , [QuarterName] = Cast('Corrupt Quarter' as nVarchar(50) )
  , [Year] = -2
  , [YearName] = Cast('Corrupt Year' as nVarchar(50) )
  Set Identity_Insert [DWNorthwindOrders].[dbo].[DimDates] Off
Go

-- 2f)Get source data from Northwind.dbo.Orders, Order Details and exiting dimension tables
-- Used with Data Flow Task "Fill FactOrders"
SELECT  
  Orders.OrderID
, DimCustomers.CustomerKey
, DimEmployees.EmployeeKey
, DimProducts.ProductKey
, OrderDateKey = OrderDate.DateKey
, RequiredDateKey =  RequiredDate.DateKey
, ShippedDateKey =  ShippedDate.DateKey
, [PriceOnOrder] = Sum([Order Details].UnitPrice)
, [QuantityOnOrder] = Sum([Order Details].Quantity)
FROM Northwind.Dbo.[Order Details] 
INNER JOIN Northwind.Dbo.Orders 
	ON Northwind.Dbo.[Order Details].OrderID = Northwind.Dbo.Orders.OrderID
INNER JOIN dbo.DimCustomers
	ON dbo.DimCustomers.CustomerID = Northwind.Dbo.Orders.CustomerID
INNER JOIN dbo.DimEmployees
	ON dbo.DimEmployees.EmployeeID = Northwind.Dbo.Orders.EmployeeID
INNER JOIN dbo.DimProducts
	ON dbo.DimProducts.ProductID = Northwind.Dbo.[Order Details].ProductID
INNER JOIN dbo.DimDates AS OrderDate
	ON  OrderDate.[Date] = IsNull(Northwind.Dbo.[Orders].OrderDate, '1900-01-01 00:00:00.000')
INNER JOIN dbo.DimDates AS RequiredDate
	ON  RequiredDate.[Date] = IsNull(Northwind.Dbo.[Orders].RequiredDate, '1900-01-01 00:00:00.000')
INNER JOIN dbo.DimDates AS ShippedDate
	ON  ShippedDate.[Date] = IsNull(Northwind.Dbo.[Orders].ShippedDate, '1900-01-01 00:00:00.000')
GROUP BY
  Orders.OrderID
, DimCustomers.CustomerKey
, DimEmployees.EmployeeKey
, DimProducts.ProductKey
, OrderDate.DateKey
, RequiredDate.DateKey
, ShippedDate.DateKey
Go

-- Step 3) Add Foreign Keys back 
--*********************************--
-- Used with Execute SQL Task "Add Foreign Key Constraints"
ALTER TABLE dbo.DimEmployees ADD CONSTRAINT
	FK_DimEmployees_DimEmployees FOREIGN KEY
	([ManagerKey]) REFERENCES dbo.DimEmployees(EmployeeKey) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimCustomers FOREIGN KEY
	(CustomerKey) REFERENCES dbo.DimCustomers(CustomerKey) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimEmployees FOREIGN KEY
	(EmployeeKey) REFERENCES dbo.DimEmployees(EmployeeKey) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimProducts FOREIGN KEY
	(ProductKey) REFERENCES dbo.DimProducts(ProductKey) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimDates_OrderDate FOREIGN KEY
	(OrderDateKey) REFERENCES dbo.DimDates([DateKey]) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimDates_RequiredDate FOREIGN KEY
	(RequiredDateKey) REFERENCES dbo.DimDates([DateKey]) 

ALTER TABLE dbo.FactOrders ADD CONSTRAINT
	FK_FactOrders_DimDates_ShippedDate FOREIGN KEY
	(ShippedDateKey) REFERENCES dbo.DimDates([DateKey]) 
Go