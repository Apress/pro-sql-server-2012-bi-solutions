/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 2
*******************************************************/

-- Listing 2-1. Sample ETL Code
-- Convert the a data string to datetime
Declare @Date Char(11)
Set @Date = '1/23/2011'
Select @Date; -- Outcome = 1/23/2011
Select Convert(datetime, @Date) -- Outcome = 2011-01-23 00:00:00.0
Go

-- Listing 2-2. Drop and create the database
-- Step 1) Drop the database as needed
Use Master
Go
If ( exists( Select Name from SysDatabases Where name = 'DWWeatherTracker' ) )
 Begin
   Alter Database [DWWeatherTracker] Set single_user With rollback immediate
   Drop Database [DWWeatherTracker]
 End 
Go

-- Step 2) Create Data Warehouse Database 
Create Database DWWeatherTracker
Go
Use DWWeatherTracker
Go


-- Listing 2-3. Creating three tables
-- Step 3) Create a Staging table to hold imported ETL data
CREATE TABLE [WeatherHistoryStaging] 
( [Date] varchar(50)
, [Max TemperatureF] varchar(50)
, [Min TemperatureF] varchar(50)
, [Events] varchar(50)
)
Go

-- Step 4) Create Dimension Tables
Create Table [DimEvents]
( [EventKey] int not null Identity
, [EventName] varchar(50) not null 
)
Go

-- Step 5) Create Fact Tables
Create Table [FactWeather]
( [Date] datetime not null
, [EventKey] int not null
, [MaxTempF] int not null
, [MinTempF] int not null 
)
Go

-- Listing 2-4. Adding the primary keys
-- Step 6) Create Primary Keys on all tables
Alter Table DimEvents Add Constraint
	PK_DimEvents primary key ( [EventKey] ) 	
Go	
Alter Table FactWeather Add Constraint
	PK_FactWeathers primary key ( [Date], [EventKey] ) 		
Go

-- Listing 2-5. Adding the foreign Foreign keysKeys
-- Step 7) Create Foreign Keys on all tables
Alter Table FactWeather Add Constraint
  	FK_FactWeather_DimEvents Foreign Key( [EventKey] ) 
	  References dbo.DimEvents ( [EventKey] ) 
Go
