-- Learn By Doing Chapter 3 -- 

--	Listing 1, Code used to review the chosen Northwind database tables.

-- review the current data in the chosen tables
Select Top 2 * From Customers
Select Top 2 * From Employees 
Select Top 2 * From Orders
Select Top 2 * From [Order Details]
Select Top 2 * From Products
Select Top 2 * From Categories

-- review the current design of the chosen tables
Use Northwind

Use Northwind
Go
Select 
  Col.TABLE_NAME
, Col.COLUMN_NAME
, DataType = Cast(DATA_TYPE as nvarchar(50))  + IsNull( '(' + Cast(CHARACTER_MAXIMUM_LENGTH  as nvarchar(50)) + ')', '')
, Const.CONSTRAINT_NAME
, TblCon.CONSTRAINT_TYPE
, Col.IS_NULLABLE
, ch.CHECK_CLAUSE
, Col.COLUMN_DEFAULT

, [Is_Identity] = Case When SysCol.is_identity = 1 then 'Yes' else 'No' End
From INFORMATION_SCHEMA.COLUMNS as Col
Left JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE as Const
  ON Col.TABLE_NAME  = Const.TABLE_NAME
  and Col.COLUMN_NAME  = Const.COLUMN_NAME
Left JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS as Ch
  ON Ch.CONSTRAINT_NAME  = Const.CONSTRAINT_NAME
Left JOIN INFORMATION_SCHEMA.Table_CONSTRAINTS as TblCon
  ON TblCon.CONSTRAINT_NAME  = Const.CONSTRAINT_NAME 
Left JOIN sys.all_columns as SysCol
  ON Object_Name(SysCol.[Object_id]) = Const.TABLE_NAME
  and SysCol.NAME  = Const.COLUMN_NAME
Where Col.TABLE_NAME 
In ( 
  'Customers'
, 'Employees'
, 'Orders'
, 'Order Details'
,  'Products' 
,  'Categories'
)
Order By  Col.TABLE_NAME , Col.ORDINAL_POSITION



