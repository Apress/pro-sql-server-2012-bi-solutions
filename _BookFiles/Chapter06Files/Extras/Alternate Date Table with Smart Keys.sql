/** Alternate Date Creation Script using "Smart Keys" **/
USE TEMPDB
Go
If Exists (Select Name from SysObjects where Name = 'AltDimDates')
  Drop Table AltDimDates
Go

CREATE TABLE [dbo].[AltDimDates](
	[DateKey] [int] NOT NULL PRIMARY KEY,
	[Date] [datetime] NOT NULL,
	[DateName] [nvarchar](50) NULL,
	[Month] [int] NOT NULL,
	[MonthName] [nvarchar](50) NOT NULL,
	[Quarter] [int] NOT NULL,
	[QuarterName] [nvarchar](50) NOT NULL,
	[Year] [int] NOT NULL,
	[YearName] [nvarchar](50) NOT NULL
)
Go

-- Create variables to hold the start and end date
Declare @StartDate datetime = '01/01/1990'
Declare @EndDate datetime = '01/01/1995' 

-- Use a while loop to add dates to the table
Declare @DateInProcess datetime
Declare @DayAsString varchar(2)  
Declare @MonthAsString varchar(2)
Declare @YearAsString varchar(4)
Set @DateInProcess = @StartDate

While @DateInProcess <= @EndDate
 Begin
 -- Extract strings for the Day, Month, and Year
Set @DayAsString = Right('0' + Cast(Day(@DateInProcess) as varchar(2)), 2 ) 
Set @MonthAsString =  Right('0' + Cast(Month(@DateInProcess) as varchar(2)), 2)  
Set @YearAsString =  Cast(Year(@DateInProcess) as varchar(4)) 

 ---- Add a row into the date dimension table for this date
 Insert Into AltDimDates 
 ( [DateKey], [Date], [DateName], [Month], [MonthName], [Quarter], [QuarterName], [Year], [YearName] )
 Values ( 
    Cast( ( @YearAsString +  @MonthAsString  + @DayAsString) as int)
  , @DateInProcess -- [Date]
  , DateName( weekday, @DateInProcess ) + ', '  
    +  DateName( month, @DateInProcess )  + ', '  
    +  @DayAsString     + ', '  
    +   @YearAsString   -- [DateName]  
  , Month( @DateInProcess ) -- [Month]   
  , DateName( month, @DateInProcess ) -- [MonthName]
        + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50) )
  , DateName( quarter, @DateInProcess ) -- [Quarter]
  , 'Q' + DateName( quarter, @DateInProcess )  -- [QuarterName] 
      + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50) )
  , Year( @DateInProcess )
  , Cast( Year(@DateInProcess ) as nVarchar(4) ) -- [YearName] 
 )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End
 
-- 2e) Add additional lookup values to DimDates
Insert Into [AltDimDates] 
  ( [DateKey]
  , [Date]
  , [DateName]
  , [Month]
  , [MonthName]
  , [Quarter]
  , [QuarterName]
  , [Year], [YearName] )
  Select 
    [DateKey] = -1
  , [Date] =  Cast('01/01/1900' as nVarchar(50) )
  , [DateName] = Cast('Unknown Day' as nVarchar(50) )
  , [Month] = -1
  , [MonthName] = Cast('Unknown Month' as nVarchar(50) )
  , [Quarter] =  -1
  , [QuarterName] = Cast('Unknown Quarter' as nVarchar(50) )
  , [Year] = -1
  , [YearName] = Cast('Unknown Year' as nVarchar(50) )
  Union
  Select 
    [DateKey] = -2
  , [Date] = Cast('01/01/1900' as nVarchar(50) )
  , [DateName] = Cast('Corrupt Day' as nVarchar(50) )
  , [Month] = -2
  , [MonthName] = Cast('Corrupt Month' as nVarchar(50) )
  , [Quarter] =  -2
  , [QuarterName] = Cast('Corrupt Quarter' as nVarchar(50) )
  , [Year] = -2
  , [YearName] = Cast('Corrupt Year' as nVarchar(50) )
Go

-- Check the tables data
Select * from AltDimDates