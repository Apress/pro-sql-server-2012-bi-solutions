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
