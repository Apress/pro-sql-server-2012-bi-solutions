
-- OTHER USEFUL TECHNIQUES WITH SQL PROGRAMMING --

-- You can copy data from one table to the other using a SELECT INTO statement.
-- this is often used to create staging tables during the ETL process.
-- for example in the  listing 6X we included code that would create a lookup table
-- And an insert statement to fill that table. Using the select into statement you can do both tasks
-- Using only one statement. when combined with the row number function you can even include a surrogate key.

Select 
    [TitleTypeKey] = ROW_NUMBER() OVER(ORDER BY [Type] asc) 
  , [OriginalTitleType] = [Type]	
  , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'										     
      When 'psychology' Then 'Psychology'										     
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     									     
    End
-- Into [TitleTypeLookup] -- This create a new table
From [Pubs].[dbo].[Titles]
Group By [Type]

-- Note while this is a quick way to create and fill a table it doesn't provide you with as many options. 
-- So, it may be best to use this for only simple ETL processes.

-- There may be times where you only want to use a table while performing ETL tasks but not have it be a persistent
-- object in your data warehouse.if that is the case you can consider creating a temporary table.
-- There are number ways to do this and we will use the lookup table as a handy example even though it is likely
-- That you would keep a lookup table as a persistent object.

-- Temporary tables can be created by prepending a single # in front of the table name.
-- These temporary tables last for the life of a connection to the SQL Server.
-- As soon as the connection is closed the table is removed from the server.
-- NOTE, these type tables are referred to as local temporary tables and 
-- are only available to the connection in which they are created.

Select
    [TitleTypeKey] = ROW_NUMBER() OVER(ORDER BY [Type] asc) 
  , [OriginalTitleType] = [Type]	
  , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'										     
      When 'psychology' Then 'Psychology'										     
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     									     
    End
INTO [#TitleTypeLookup]
From [Pubs].[dbo].[Titles]
Group By [Type]

-- Temporary tables created by prepending a double # last until the SQL Server database engine is restarted. 
-- These type of tables are available to all connections on the SQL Server that they were created.
Select
    [TitleTypeKey] = ROW_NUMBER() OVER(ORDER BY [Type] asc) 
  , [OriginalTitleType] = [Type]	
  , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'										     
      When 'psychology' Then 'Psychology'										     
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     									     
    End
INTO [##TitleTypeLookup]
From [Pubs].[dbo].[Titles]
Group By [Type]

-- If you want to create a temporary table that will last for only the life of the queries processing
-- you can build a pseudo-table.  Pseudo-tables tables can be created in a couple ways.

-- One way is to use a sub query to create the pseudo-table.
Select * from  (
  Select 
      [TitleTypeKey] = ROW_NUMBER() OVER(ORDER BY [Type] asc) 
    , [OriginalTitleType] = [Type]	
    , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
        When 'business' Then 'Business'
        When 'mod_cook' Then 'Modern Cooking'						     
        When 'popular_comp' Then 'Popular Computing'										     
        When 'psychology' Then 'Psychology'										     
        When 'trad_cook' Then 'Traditional Cooking'	
        When 'UNDECIDED' Then 'Undecided'							     									     
      End
  From [Pubs].[dbo].[Titles]
  Group By [Type]
) as  [TitleTypeLookup_pseudo-table] 

-- Another way to create a pseudo-table is using a Common Table Expression (CTE).
With [TitleTypeLookup_pseudo-table] 
( [TitleTypeKey], [OriginalTitleType], [CleanTitleType] ) 
as (
  Select 
      ROW_NUMBER() OVER(ORDER BY [Type] asc) 
    , [Type]	
    , Case Cast( [type] as nvarchar(50) )
        When 'business' Then 'Business'
        When 'mod_cook' Then 'Modern Cooking'						     
        When 'popular_comp' Then 'Popular Computing'										     
        When 'psychology' Then 'Psychology'										     
        When 'trad_cook' Then 'Traditional Cooking'	
        When 'UNDECIDED' Then 'Undecided'							     									     
      End
  From [Pubs].[dbo].[Titles]
  Group By [Type]
)  
Select * from [TitleTypeLookup_pseudo-table] 

-- Yet another way to create a pseudo-table is using a table variable
Declare @TitleTypeLookup_pseudotable  table  ( 
    [TitleTypeKey] int Primary Key  
  , [OriginalTitleType] nvarchar(50)
  , [CleanTitleType] nvarchar(50)
)
Insert into @TitleTypeLookup_pseudotable (   
    [TitleTypeKey] 
  , [OriginalTitleType] 
  , [CleanTitleType] 
)
Select 
    [TitleTypeKey] = ROW_NUMBER() OVER(ORDER BY [Type] asc) 
  , [OriginalTitleType] = [Type]	
  , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'										     
      When 'psychology' Then 'Psychology'										     
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     									     
    End
From [Pubs].[dbo].[Titles]
  Group By [Type]
 
Select * from @TitleTypeLookup_pseudotable 

-- Note: using a table variable give you greater control over the pseudo-table than previous options
-- but is nearly equivalent to just creating the staging table syntactically. its main advantage
-- is that the table will be dropped as soon as the batch of SQL statements that created it are completed.
-- this can be handy when creating ETL stored procedures. In a typical ETL stored procedure you could fill your
-- Lookup tables, perform the lookup, fill the associated table with the transformed data, and delete the lookup table.
-- if you perform these actions using a standard or temporary table the log file will be utilized. However,
-- in a pseudo-table all actions are handled in RAM and are not logged. That is unless you run out of RAM and need
-- paging operations. pseudo-tables are a clean simple way to handle ETL processing in stored procedures and provide
-- additional performance advantages when the these processes are small.


-- Data can also be extracted from a file using the BULK INSERT command.
Bulk Insert myTestCharData 
   FROM 'C:\myTestCharData-c.Dat' 
   WITH (
      DATAFILETYPE='char',
      FIELDTERMINATOR=','
   ); 
GO
SELECT Col1,Col2,Col3 FROM myTestCharData;
GO



