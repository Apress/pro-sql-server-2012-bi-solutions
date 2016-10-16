--****************** Incremental ETL *********************--
-- This file highlights some of the most commonly used
-- ways to track changes to data for ETL Processing.
--**********************************************************--

Create Database TrackingChangesDB
Go

Use TrackingChangesDB
Go

'*** Tracking Changes with Triggers ***'
-----------------------------------------------------------------------------------------------------------------------
-- Perhaps the oldest way of tracking tables changes is by the use of Triggers
Create -- Drop
Table Customers
( CustomerId int, CustomerName varchar(50))
Go

-- Often these trigger used with builtin functions, such as...
Select GetDate(), sUser_sName(), User

-- This simple trigger shows how the Inserted and Deleted pseudo tables work.
Create -- Alter
Trigger tCustomers
	On Customers
	For Insert, Update, Delete
AS
  Select CustomerId as [InsCustomerId], CustomerName, GetDate(), sUser_sName(), User from Inserted
  Select CustomerId as [delCustomerId], CustomerName, GetDate(), sUser_sName(), User from Deleted
Go

-- Now let's try some transactional statement
Insert into Customers (CustomerId, CustomerName) 
	Values(1, 'Bob Smith')
Select * from Customers
Go

Update Customers 
	Set CustomerName = 'Robert Smith' 
	Where CustomerId = 1
Select * from Customers
Go

Delete From Customers 
	Where CustomerId = 1
Select * from Customers
Go

-- One way to capture data changes it to create a tracking table and use the trigger to automatically
-- add data to it when changes occure to the table you want to monitor. 
Create -- Drop
Table CustomersChanges
( CustomerId int, CustomerName varchar(50), DateAdded datetime, TransactionType Char(1))
Go

-- Now create a Trigger that uses the Tracking table.
Alter
Trigger tCustomers
	On Customers
	For Insert, Update, Delete
AS
-- Check for Update
If (((Select Count(*) from Inserted) > 0) and ((Select Count(*) from Deleted) > 0))
	Begin
		Insert into CustomersChanges(CustomerId, CustomerName, DateAdded, TransactionType)
		Select CustomerId, CustomerName, GetDate(), 'u' from Inserted
	End
-- Check for Insert	
Else If ((Select Count(*) from Inserted) > 0)	
	Begin
		Insert into CustomersChanges(CustomerId, CustomerName, DateAdded, TransactionType)
		Select CustomerId, CustomerName, GetDate(), 'i' from Inserted
	End
-- Check for Delete
Else If ((Select Count(*) from Deleted) > 0)	
	Begin
		Insert into CustomersChanges(CustomerId, CustomerName, DateAdded, TransactionType)
		Select CustomerId, CustomerName, GetDate(), 'd' from Deleted
	End	
Go

-- let's try those transactional statements once again
Insert into Customers (CustomerId, CustomerName)  
	Values(1, 'Bob Smith')
Select * from CustomersChanges
Go

Update Customers 
	Set CustomerName = 'Robert Smith' 
	Where CustomerId = 1
Select * from CustomersChanges
Go

Delete From Customers 
	Where CustomerId = 1
Select * from CustomersChanges
Go

-- Reset Demo --
Drop Table Customers
	-- Drop Trigger trCustomers <-- This is Not needed, since dropping the table it's bound to drops the trigger
Drop Table CustomersChanges

Go

'*** Tracking with a RowVersion column ***'
-----------------------------------------------------------------------------------------------------------------------
-- The RowVersion (or Timestamp) data type automatically increments whenever a change happen on a table row.
-- These VALUES are always automatic and cannot be added manually.
-- They are also always unique thoughout a particular database.
-- This data type is equivelant to the binary(8) data type which can be added manually to a table

-- Let's make a new table and test this out...
Create -- Drop
Table Customers
( CustomerId int, CustomerName varchar(50), ChangeTracker RowVersion)
Go

-- Now lets try a transaction statement
Insert into Customers(CustomerId, CustomerName) 
	Values(1, 'Bob Smith')
Select * from Customers
Go
 
-- You can still capture data changes using a tracking table and repeatly checking 
-- for changes in the timestampe column.  
Create -- Drop
Table CustomersChanges
( CustomerId int, CustomerName varchar(50), ChangeTracker binary(8),  DateCopied datetime, TransactionType Char(3))
Go

-- Now they are out of sync
Select * from Customers
Select * From CustomersChanges

-- We can use the EXCEPT Clasuse 
-- to Isolate the differences between tables
Select CustomerId, CustomerName, Cast(ChangeTracker as binary(8)) from Customers
Except -- EXCEPT returns any distinct values from the "First" query that are not found in the "Second" query.
Select CustomerId, CustomerName, ChangeTracker from CustomersChanges

-- Combining the EXCEPT Class with an Insert statement 
-- can be use to Syncronize tables for new Inserts or Updates...
Insert into CustomersChanges(CustomerId, CustomerName,ChangeTracker, DateCopied, TransactionType )
	Select CustomerId, CustomerName, Cast(ChangeTracker as binary(8)), GetDate(), 'i|u' from Customers
	Except -- EXCEPT returns any distinct values from the "First" query that are not also found on the "Second" query.
	Select CustomerId, CustomerName, ChangeTracker, GetDate(), 'i|u' from CustomersChanges
	
-- Now they are syncronized
Select * from Customers
Select * From CustomersChanges	
Go

/* NOTE:
** Normally you would place this insert code a Store Procedure and force developers to use it
** instead of inserting directly into a tables. We could use conditional logic in the Store Procedure as 
** well to tell the difference between and Insert or an Update. By addeding "Insert Flag" column to 
** the Customers table. However, for simplicty we will skip that in this demo. 
*/ 

-- Now they Let's add some more data, which will make it out of sync once more.
Insert into Customers(CustomerId, CustomerName) 
	Values(2, 'Sue Jones')
Select * from Customers
Select * From CustomersChanges
Go

-- Syncronize tables for new Inserts or Updates...
Insert into CustomersChanges(CustomerId, CustomerName,ChangeTracker, DateCopied, TransactionType  )
	Select CustomerId, CustomerName, Cast(ChangeTracker as binary(8)), GetDate(), 'i|u' from Customers
	Except
	Select CustomerId, CustomerName, ChangeTracker, GetDate(), 'i|u' from CustomersChanges
Go

-- Now they are syncronized again
Select * from Customers
Select * From CustomersChanges	
Go

-- Now they are out of sync, yet again.
Update Customers
	Set CustomerName = 'Robert Smith'
	Where CustomerId = 1
Select * from Customers
Select * From CustomersChanges
Go

-- Syncronize tables for new Inserts or Updates...
Insert into CustomersChanges(CustomerId, CustomerName,ChangeTracker, DateCopied, TransactionType )
	-- Note that this select statement runs BEFORE the insert takes place!
	Select CustomerId, CustomerName, Cast(ChangeTracker as binary(8)), GetDate(), 'i|u' from Customers
	Except
	Select CustomerId, CustomerName, ChangeTracker, GetDate(), 'i|u' from CustomersChanges
Go

-- Now they are syncronized again
Select * from Customers
Select * From CustomersChanges	 
Go

-- Now they are out of sync, once more.
Delete From Customers
	Where CustomerId = 1
Select * from Customers
Select * From CustomersChanges
Go

-- Since the Except option always check the first table against the second we do not see the deletion.
Select CustomerId, CustomerName, Cast(ChangeTracker as binary(8)), GetDate(), 'i|u' from Customers
Except
Select CustomerId, CustomerName, ChangeTracker, GetDate(), 'i|u' from CustomersChanges


-- However Changing the order of tables will allow us to do so!
Select CustomerId, CustomerName, ChangeTracker, GetDate(), 'd' from CustomersChanges
Except
Select CustomerId, CustomerName, Cast(ChangeTracker as binary(8)), GetDate(), 'd' from Customers


-- Syncronize tables for new Deletes...
Update CustomersChanges 
Set TransactionType = 'd'
	Where CustomerId In (
			Select CustomerId from CustomersChanges
			Except
			Select CustomerId from Customers
		)
Select * from Customers
Select * From CustomersChanges
Go

-- OR -- 
Delete From CustomersChanges 
	Where CustomerId In (
			Select CustomerId from CustomersChanges
			Except
			Select CustomerId from Customers
		)
Select * from Customers
Select * From CustomersChanges	 
Go


-- As Mentioned, the problem with the our Except option is you cannot 
-- distinguish between the Insert and Update transactions.
-- However, when we do a similar thing using a set of Join statements we can tell the difference.


Update Customers
	Set CustomerName = 'Sue Thomson' 
	Where CustomerId = 2
Go
--Check for Inserts
Select Customers.CustomerId, Customers.CustomerName, Cast(Customers.ChangeTracker as binary(8)) 
From Customers Join CustomersChanges
	On Customers.CustomerId != CustomersChanges.CustomerId
	AND Customers.CustomerName != CustomersChanges.CustomerName
	AND Customers.ChangeTracker != CustomersChanges.ChangeTracker
-- (0 row(s) affected)	

-- Check for Update on [CustomerId] column
Select Customers.CustomerId, Customers.CustomerName, Cast(Customers.ChangeTracker as binary(8)) 
From Customers Join CustomersChanges
	On Customers.CustomerId != CustomersChanges.CustomerId
	AND Customers.CustomerName = CustomersChanges.CustomerName
	AND Customers.ChangeTracker != CustomersChanges.ChangeTracker
-- (0 row(s) affected)	

-- Check for Update on [CustomerName] column
Select Customers.CustomerId, Customers.CustomerName, Cast(Customers.ChangeTracker as binary(8)) 
From Customers Join CustomersChanges
	On Customers.CustomerId = CustomersChanges.CustomerId
	AND Customers.CustomerName != CustomersChanges.CustomerName
	AND Customers.ChangeTracker != CustomersChanges.ChangeTracker

/* NOTE:
** By creating a Stored Procedure, placing these joins within it, and using them to determine
** which type of transaction would would need to sync the tacking table. We would have 
** a better tracking system. 
** Or,  we could just use a Trigger :-0
** Its a shame that Triggers are "Bad". ;-) 
*/

-- Reset Demo --
Drop Table Customers
Drop Table CustomersChanges
Go

'*** Tracking with a Flag column ***'
-----------------------------------------------------------------------------------------------------------------------
-- Another common method of Tracking changes is by including a flag in the original table:
-- Typical flags are (i)Inserted, (u)Updated, (d)Deleted, (null)Unchanged
Create -- Drop
Table Customers
( CustomerId int, CustomerName varchar(50), RowStatus Char(1) check(RowStatus in ('i','u','d')) )
Go

-- Now let's try some transactional statements.
Insert into Customers (CustomerId, CustomerName, RowStatus) 
	Values(1, 'Bob Smith', 'i')
Select * from Customers
Go

-- Now when we import data to a replica table we just reset the flags to null 
Create -- Drop
Table CustomersChangeTracker
( CustomerId int, CustomerName varchar(50), DateAdded datetime, TransactionType Char(1))
Go

-- Copy the data from the Customers table
Create -- Drop
Proc pSyncByFlag
as
-- Get the changed data...
Insert into CustomersChangeTracker (CustomerId, CustomerName, DateAdded, TransactionType) 
	Select CustomerId, CustomerName, GetDate(), RowStatus 
	From Customers
	Where RowStatus is not null
--... and reset the flags
Update Customers Set RowStatus = null
-- We will, display the tables contents for testing
Select * from Customers
Select * from CustomersChangeTracker
Go

-- Ok, let sync the tables
Exec pSyncByFlag
Go

-- Now, let's do somemore transactional statements.
Insert into Customers (CustomerId, CustomerName, RowStatus) 
	Values(2, 'Sue Jones', 'i')

Update Customers 
	Set CustomerName = 'Robert Smith' 
		, RowStatus = 'u'
	Where CustomerId = 1
Select * from Customers	
Go	

Exec pSyncByFlag
Go	
	
-- When we need to Delete From Customers, we use an update instead!
Update Customers 
	Set RowStatus = 'd'
	Where CustomerId = 2
	
Select * from Customers
Go

Exec pSyncByFlag
Go	


-- Reset Demo --
Drop Table Customers
Drop Table CustomersChanges
Go

/* NOTE:
** When we use a Tracking table, the process is sometimes referred to as a 
** Type 4 SCD(Slow Changing Dimension). This is a term use with Data Warehousing.
** We, will take a look at Types 1, 2, and 3 next.
*/

'*** Tracking with Slow Changing Dimension columns ***'
-----------------------------------------------------------------------------------------------------------------------
-- Type 1 (aka: "No One Really Cares")
-- In These SCD, you just overwrite the existing data and forget it!
Create -- Drop
Table Customers
( CustomerId int, CustomerName varchar(50))
Go

-- Add a new row
Insert into Customers (CustomerId, CustomerName ) 
	Values(1, 'Bob Smith')
Select * from Customers
Go

-- Change an Existing row
Update Customers 
	Set CustomerName = 'Robert Smith' 
	Where CustomerId = 1
Select * from Customers


-- Type 3 (aka: "What was it last time?")
-- This method tracks previous value using separate columns
-- In These SCD, you just overwrite the existing data and forget it!
Create -- Drop
Table Customers
( CustomerId int, CustomerName varchar(50), OldCustomerName varchar(50))
Go

-- Add a new row
Insert into Customers (CustomerId, CustomerName, OldCustomerName ) 
	Values(1, 'Bob Smith', Null)
Select * from Customers
Go

-- Change an Existing row
Update Customers 
	Set CustomerName = 'Robert Smith'
	, OldCustomerName = 'Bob Smith'	 
	Where CustomerId = 1
Select * from Customers


-- Type 2 (aka: "I want it all!")
-- This popular method tracks an infinite number of versions by just adding 
-- a Version column to the table and forcing people to do only inserts
-- instead of deletes.

Create -- Drop
Table Customers (
  CustomerId int
, CustomerName varchar(50)
, VersionId int
Primary Key (CustomerId, VersionId ) 
)
Go

-- Add a new row
Insert into Customers (CustomerId, CustomerName, VersionId ) 
	Values(1, 'Bob Smith', 0)
Select * from Customers
Go

-- Change an Existing row by Adding a new one with a new VersionId
Insert into Customers (CustomerId, CustomerName, VersionId ) 
	Values(1, 'Rober Smith', 1)
Select * from Customers
Go


-- Type 2 part b (aka: "I still want more!")
-- You can enhance your version control, and provide more accurtate 
-- reporting against the table, by adding a way to track when the 
-- version was in effect.

Create -- Drop
Table Customers (
  CustomerId int
, CustomerName varchar(50)
, VersionId int
, StartDate DateTime
Primary Key (CustomerId, VersionId ) 
)
Go

-- Add a new row
Insert into Customers (CustomerId, CustomerName, VersionId, StartDate) 
	Values(1, 'Bob Smith', 0, GetDate() )
Select * from Customers
Go

-- Change an Existing row by Adding a new one with a new VersionId and the new date
Insert into Customers (CustomerId, CustomerName, VersionId, StartDate) 
	Values(1, 'Robert Smith', 1, GetDate() )
Select * from Customers
Go


-- Type 2 part c (aka: "I can't get enough of that sweet tracking stuff!")
-- You can just keep adding more information about the row changes by adding 
-- additional columns. Keep in mind though the when a SCD table
-- has a lot of changes over a short time (in otherwords it not all that slow)
-- you can create a performance issue for yourself.

Create -- Drop
Table Customers (
  CustomerId int
, CustomerName varchar(50)
, VersionId int
, StartDate DateTime
, EndDate DateTime
, AddedBy varchar(50)
Primary Key (CustomerId, VersionId ) 
)
Go

-- Add a new row
Insert into Customers (CustomerId, CustomerName, VersionId, StartDate, EndDate, AddedBy) 
	Values(1, 'Bob Smith', 0, GetDate(), Null, sUser_sName() )
Select * from Customers
Go

-- Change an Existing row by 
-- 1) Updating the exiting row with the new EndDate
-- 2) Adding a new row with a new VersionId and StartDate  
Declare @Now DateTime
Declare @CustId int
Declare @VerId int

Select @CustId = 1, @VerId = 0, @Now = GetDate()

Update Customers
Set EndDate = @Now 
Where CustomerId = @CustId and @VerId = 0

Insert into Customers (CustomerId, CustomerName, VersionId, StartDate, EndDate, AddedBy ) 
	Values(@CustId, 'Robert Smith', @VerId + 1 , @Now, null, sUser_sName()  )
Select * from Customers
Go

-- Reset Demo --
Drop Table Customers
Use Master
Go


/************ Incremental loading with Merge ***********
Since 2005 the Merge command has made it easier to do an incremental load
of data warehouse tables.
**********************************************/

Use TempDB
Go
Create -- DROP
Table Sales
( Order_Id int, Product_Id int, QTY int)

Create -- DROP
Table FactSales
( OrderId int, ProductId int, SalesQty int)

-- Add some Sales
INSERT INTO Sales VALUES (1,100,65)
INSERT INTO Sales VALUES (1,200,10)
INSERT INTO Sales VALUES (2,200,423)

-- Now only the OLTP table has data 
SELECT * FROM Sales
SELECT * FROM FactSales

-- Sync the tables with the Merge command
MERGE FactSales AS TargetTable
 USING 
 ( SELECT Order_Id, Product_Id, QTY FROM Sales ) 
	AS SourceTable ( OrderId, ProductId, SalesQty )
 ON
 (   TargetTable.OrderId = SourceTable.OrderId 
 AND TargetTable.ProductId = SourceTable.ProductId  )
 WHEN NOT MATCHED THEN
       INSERT (OrderId, ProductId, SalesQty )
       VALUES( SourceTable.OrderId, SourceTable.ProductId, SourceTable.SalesQty)
 WHEN MATCHED THEN
       UPDATE
        SET 
		TargetTable.SalesQty = SourceTable.SalesQty
		; -- Merges requires a simi-colon

-- Now that tables both have data and are in sync
SELECT * FROM Sales
SELECT * FROM FactSales

-- Let's test the update
UPDATE Sales
SET QTY = 100
WHERE Order_Id = 1 AND Product_Id = 100 


-- OUT of Sync, again!
SELECT * FROM Sales
SELECT * FROM FactSales


-- Sync it using Merge!
MERGE FactSales AS TargetTable
 USING 
 ( SELECT Order_Id, Product_Id, QTY FROM Sales ) 
	AS SourceTable ( OrderId, ProductId, SalesQty )
 ON
 (   TargetTable.OrderId = SourceTable.OrderId 
 AND TargetTable.ProductId = SourceTable.ProductId  )
 WHEN NOT MATCHED THEN
       INSERT (OrderId, ProductId, SalesQty )
       VALUES( SourceTable.OrderId, SourceTable.ProductId, SourceTable.SalesQty)
 WHEN MATCHED THEN
       UPDATE
        SET 
		TargetTable.SalesQty = SourceTable.SalesQty
		; -- Merges requires a simi-colon

-- Back in Sync!
SELECT * FROM Sales
SELECT * FROM FactSales


-- Adding Delete to the mix
DELETE FROM Sales
WHERE Order_Id = 2

-- OUT of  Sync!
SELECT * FROM Sales
SELECT * FROM FactSales

-- Adding Deletion code using the By Target and By Source commands
MERGE FactSales AS TargetTable
 USING 
 ( SELECT Order_Id, Product_Id, QTY FROM Sales ) 
	AS SourceTable ( OrderId, ProductId, SalesQty )
 ON
 (   TargetTable.OrderId = SourceTable.OrderId 
 AND TargetTable.ProductId = SourceTable.ProductId  )
 WHEN NOT MATCHED BY TARGET THEN
       INSERT (OrderId, ProductId, SalesQty )
       VALUES( SourceTable.OrderId, SourceTable.ProductId, SourceTable.SalesQty)
 WHEN NOT MATCHED BY SOURCE THEN
	   DELETE   
 WHEN MATCHED THEN
       UPDATE
        SET 
		TargetTable.SalesQty = SourceTable.SalesQty
		; -- Merges requires a simi-colon

-- Back in Sync!
SELECT * FROM Sales
SELECT * FROM FactSales


'*** Tracking with Change Data Capture (CDC) ***'
-----------------------------------------------------------------------------------------------------------------------
-- Microsoft figured that they would simplify things by adding a internal tracking
-- System of thier own. This system reads the changes recorded in the .LDF log file
-- and them to a Change Table.

-- To use CDC follow these steps
-- 1) Turn CDC on for a given Database
-- 2) Turn CDC on for a given Table

-- Step 1) Turn CDC on for a given Database
Create Database MS_TrackingChangesDB
Go
Use MS_TrackingChangesDB
Go
Exec sys.sp_CDC_Enable_db
Go

-- 2) Turn CDC on for a given Table
/*
	sys.sp_cdc_enable_table 
		[ @source_schema = ] 'source_schema', 
		[ @source_name = ] 'source_name' ,
		[ @role_name = ] 'role_name'
		[,[ @capture_instance = ] 'capture_instance' ] 
		[,[ @supports_net_changes = ] supports_net_changes ]
		[,[ @index_name = ] 'index_name' ]
		[,[ @captured_column_list = ] 'captured_column_list' ] -- Chose which columns to track
		[,[ @filegroup_name = ] 'filegroup_name' ]
	  [,[ @partition_switch = ] 'partition_switch' ]
*/

Create -- Drop
Table Customers -- Note that we need a PK in order for this to work right
( CustomerId int Primary Key, CustomerName varchar(50))
Go

'Note: Turn on SQL Agent, since CDC relies on SQL Jobs to work!'

EXEC sys.sp_CDC_Enable_Table
    @source_schema = N'dbo' 
  , @source_name = N'Customers' -- Name of the table you want to track
  , @role_name = N'cdc_admin' -- This role will be created automaticlly if it does not exist
  , @supports_net_changes = 1 -- if set to 1 it will create two new functions, 
											   -- one for all changes and one for only the net change.
  , @capture_instance =  'Customers' -- This can be used to categorize the LSN										   
Go

--  when CDC is enable one or two new functions are created as well 
-- (depending on the @supports_net_changes setting)
Select * from SysObjects where name like '%cdc%'
Select * from SysObjects where name like '%Customers%'

-- Of course, Mircosoft added other Views and Functions that can help with CDC as well
SELECT * FROM sys.change_tracking_tables
SELECT * FROM sys.dm_cdc_errors
SELECT * FROM sys.dm_cdc_log_scan_sessions
Select sys.fn_cdc_get_min_lsn('Customers') -- This refers to the @capture_instance name
Select sys.fn_cdc_get_max_lsn()

-- Now, that the the feature is turned on, a Tracking table has been added.
-- using the pattern cdc.schema_tablename_CT as it's name. 
-- NOTE: This seems to be buggy. So, check SysObject to see what the name actually is.
Select * from cdc.dbo_Customers_CT
Go
sp_help [cdc.dbo_Customers_CT]


-- OK, lets make some changes 
Insert into Customers (CustomerId, CustomerName) 
	Values(1, 'Bob Smith')
Select * from Customers
Go
Insert into Customers (CustomerId, CustomerName) 
	Values(1, 'Sue Jones')
Select * from Customers
Go
Select * from cdc.dbo_Customers_CT
Go

Update Customers 
	Set CustomerName = 'Robert Smith' 
	Where CustomerId = 1
Select * from Customers
Go
Select * from cdc.dbo_Customers_CT
Go

Delete From Customers 
	Where CustomerId = 1
Select * from Customers
Go
Select * from cdc.dbo_Customers_CT
Go

-- Records in the table will be cleared out by a SQL Job every 3 days. 
-- This is called the Validity Interval and can be adjusted if needed. 
SELECT * FROM sys.change_tracking_databases


-- You can isolate todays changes with code like this 
Select Start_LSN, End_LSN, Last_Commit_Time, Convert(varchar(50), GetDate(), 101) as [Today]
	From sys.dm_cdc_log_scan_sessions
	Where Convert(varchar(50), Last_Commit_Time, 101) =  Convert(varchar(50), GetDate(), 101)
-- Select Convert(varchar(50), GetDate(), 101)

-- The Parameters require Log Sequence Number (LSN) to work.
-- You can get these from the  sys.dm_cdc_log_scan_sessions view
-- Luckily, we just so happen to have some LSN available from 
DECLARE @From_LSN binary(10), @To_LSN binary(10)
Select @From_LSN = sys.fn_cdc_get_min_lsn('Customers') 
Select @To_LSN = sys.fn_cdc_get_max_lsn()
SELECT * 
	FROM [cdc].[fn_cdc_get_ALL_changes_Customers] (
				   @From_LSN
				  , @To_LSN
				  , N'all')
			  
SELECT * 
	FROM [cdc].[fn_cdc_get_NET_changes_Customers] (
				   @From_LSN
				  , @To_LSN
				  , N'all')				  
GO

'NOTE: if the LSN is not in the correct range you will get a "Bogus" error message"

Msg 313, Level 16, State 3, Line 4
An insufficient number of arguments were supplied for the procedure or function cdc.fn_cdc_get_all_changes_ ... . '


-- Microsoft figured that people would want to create then OWN Sprocs or Functions to get this info.
-- So, they provided a Wrapper function to aid in creating them.
Create Table #WrapperCode
(FunctionName SysName, SourceCode nVarChar(max))
Go
Insert into #WrapperCode
	Exec sys.sp_cdc_generate_Wrapper_Function
Go
Select * from #WrapperCode

-- Now we just need to create them
create function [fn_all_changes_Customers]   ( @start_time datetime = null,    @end_time datetime = null,    @row_filter_option nvarchar(30) = N'all'   )   returns @resultset table ( [__CDC_STARTLSN] binary(10), [__CDC_SEQVAL] binary(10), [CustomerId] int, [CustomerName] varchar(50),  [__CDC_OPERATION] varchar(2)     ) as   begin    declare @from_lsn binary(10), @to_lsn binary(10)         if (@start_time is null)     select @from_lsn = [sys].[fn_cdc_get_min_lsn]('Customers')    else    begin     if ([sys].[fn_cdc_map_lsn_to_time]([sys].[fn_cdc_get_min_lsn]('Customers')) > @start_time) or        ([sys].[fn_cdc_map_lsn_to_time]([sys].[fn_cdc_get_max_lsn]()) < @start_time)      select @from_lsn = null     else      select @from_lsn = [sys].[fn_cdc_increment_lsn]([sys].[fn_cdc_map_time_to_lsn]('largest less than or equal',@start_time))    end        if (@end_time is null)     select @to_lsn = [sys].[fn_cdc_get_max_lsn]()    else    begin     if [sys].[fn_cdc_map_lsn_to_time]([sys].[fn_cdc_get_max_lsn]()) < @end_time      select @to_lsn = null     else      select @to_lsn = [sys].[fn_cdc_map_time_to_lsn]('largest less than or equal',@end_time)    end        if @from_lsn is not null and @to_lsn is not null and     (@from_lsn = [sys].[fn_cdc_increment_lsn](@to_lsn))     return         insert into @resultset    select [__$start_lsn] as [__CDC_STARTLSN], [__$seqval] as [__CDC_SEQVAL], [CustomerId], [CustomerName],      case [__$operation]      when 1 then 'D'      when 2 then 'I'      when 3 then 'UO'      when 4 then 'UN'      when 5 then 'M'      else null     end as [__CDC_OPERATION]       from [cdc].[fn_cdc_get_all_changes_Customers](@from_lsn, @to_lsn, @row_filter_option) order by [__$seqval], [__$operation]        return   end
GO
create function [fn_net_changes_Customers]   ( @start_time datetime = null,    @end_time datetime = null,    @row_filter_option nvarchar(30) = N'all'   )   returns @resultset table (  [CustomerId] int, [CustomerName] varchar(50),  [__CDC_OPERATION] varchar(2)     ) as   begin    declare @from_lsn binary(10), @to_lsn binary(10)         if (@start_time is null)     select @from_lsn = [sys].[fn_cdc_get_min_lsn]('Customers')    else    begin     if ([sys].[fn_cdc_map_lsn_to_time]([sys].[fn_cdc_get_min_lsn]('Customers')) > @start_time) or        ([sys].[fn_cdc_map_lsn_to_time]([sys].[fn_cdc_get_max_lsn]()) < @start_time)      select @from_lsn = null     else      select @from_lsn = [sys].[fn_cdc_increment_lsn]([sys].[fn_cdc_map_time_to_lsn]('largest less than or equal',@start_time))    end        if (@end_time is null)     select @to_lsn = [sys].[fn_cdc_get_max_lsn]()    else    begin     if [sys].[fn_cdc_map_lsn_to_time]([sys].[fn_cdc_get_max_lsn]()) < @end_time      select @to_lsn = null     else      select @to_lsn = [sys].[fn_cdc_map_time_to_lsn]('largest less than or equal',@end_time)    end        if @from_lsn is not null and @to_lsn is not null and     (@from_lsn = [sys].[fn_cdc_increment_lsn](@to_lsn))     return         insert into @resultset    select  [CustomerId], [CustomerName],      case [__$operation]      when 1 then 'D'      when 2 then 'I'      when 3 then 'UO'      when 4 then 'UN'      when 5 then 'M'      else null     end as [__CDC_OPERATION]       from [cdc].[fn_cdc_get_net_changes_Customers](@from_lsn, @to_lsn, @row_filter_option)          return   end
GO

-- Now we can use them like so...


'Now, wasnt that easier??? (if you actually got it working that is)'
-- Turning Off CDC on a table (aka: Please make it Stop!)
EXECUTE sys.sp_cdc_disable_table 
    @source_schema = N'dbo', 
    @source_name = N'Customers',
    @capture_instance = N'all';

