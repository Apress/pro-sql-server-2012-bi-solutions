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