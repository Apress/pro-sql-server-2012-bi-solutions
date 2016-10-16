/************************************************ 
1) Make a copy of the empty database 
before starting the ETL process
************************************************/

BACKUP DATABASE [DWNorthwindOrders] 
TO  DISK = 
N'C:\_BISolutions\NorthwindFoods\DWNorthwindOrders_BeforeETL.bak'
WITH 
  INIT
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
N'C:\_BISolutions\NorthwindFoods\DWNorthwindOrders_BeforeETL.bak'
WITH REPLACE
GO
