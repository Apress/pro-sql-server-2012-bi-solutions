/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 4
*******************************************************/

-- Listing 4-1. An Expression Describing a Data Mart
/* Data Warehouse = a set of data marts {Sales Data Mart, Inventory Data Mart} */
Select * from FactSales
Select * from FactInventory -- Does not actually exist!
