-- Listing 6-17. Adding additional lookup values to the DimDates table 
Set Identity_Insert [DimDates] On
INSERT INTO [DWPubsSales].[dbo].[DimDates] ( 
   [DateKey] -- This is normally added automatically
 , [Date]
 , [DateName]
 , [Month]
 , [MonthName]
 , [Quarter]
 , [QuarterName]
 , [Year]
 , [YearName]
 )
VALUES
 ( -1 -- This will be the Primary key for the first lookup value 
 , '01/01/1900'
 , 'Unknown Day'
 , -1
 , 'Unknown Month'
 , -1
 , 'Unknown Quarter'
 , -1 
 , 'Unknown Year' 
 )
,  -- add a second row
( -2 -- This will be the Primary key for the second lookup value
 , '02/01/1900'
 , 'Corrupt Day'
 , -2
 , 'Corrupt Month'
 , -2
 , 'Corrupt Quarter'
 , -2 
 , 'Corrupt Year' 
 )
Set Identity_Insert [DimDates] Off
