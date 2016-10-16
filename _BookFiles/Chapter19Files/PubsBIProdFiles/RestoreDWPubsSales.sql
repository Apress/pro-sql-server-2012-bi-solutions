-- Check to see if they already have a database with this name...
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DWPubsSales')
  BEGIN
  -- If they do, they need to close connections to the DWPubsSales database, with this code!
    ALTER DATABASE [DWPubsSales] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  END

-- Now now restore the Empty database...
USE Master 
RESTORE DATABASE [DWPubsSales] 
FROM DISK = N'\\RSLAPTOP2\PubsBIProdFiles\DWPubsSales_BeforeETL.bak'
WITH REPLACE
GO
