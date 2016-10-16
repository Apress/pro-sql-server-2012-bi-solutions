USE [master]
-- Remove any users that are connected, include your SSIS package!
ALTER DATABASE [DWPubsSales] 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
-- Restore the database from the authors backup file.
-- Make sure the path is correct!
RESTORE DATABASE [DWPubsSales] 
FROM DISK = N'C:\_BookFiles\Chapter08Files\FilledDWPubsSalesDB.bak' 
WITH REPLACE
GO
-- Let other connections use the database again.
ALTER DATABASE [DWPubsSales] 
    SET MULTI_USER

-- Check the tables for data...
USE [DWPubsSales]
GO
Select [Rows in DimAuthors] = Count(*) From [dbo].[DimAuthors]
Select [Rows in DimDates] = Count(*) From [dbo].[DimDates]
Select [Rows in DimPublishers] = Count(*) From [dbo].[DimPublishers]
Select [Rows in DimStores] = Count(*) From [dbo].[DimStores]
Select [Rows in DimTitles] = Count(*) From [dbo].[DimTitles]
Select [Rows in FactSales] = Count(*) From [dbo].[FactSales]
Select [Rows in FactTitlesAuthors] = Count(*) From [dbo].[FactTitlesAuthors]




