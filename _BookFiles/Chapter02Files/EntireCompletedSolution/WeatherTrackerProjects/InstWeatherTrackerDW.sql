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

-- Step 3) Create a Staging table to hold imported ETL data
CREATE TABLE [WeatherHistoryStaging] 
( [Date] varchar(50)
, [Max TemperatureF] varchar(50)
, [Min TemperatureF] varchar(50)
, [Events] varchar(50)
)

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

-- Step 6) Create Primary Keys on all tables
Alter Table DimEvents Add Constraint
	PK_DimEvents primary key ( [EventKey] ) 	
Go	
Alter Table FactWeather Add Constraint
	PK_FactWeathers primary key ( [Date], [EventKey] ) 		
Go

-- Step 7) Create Foreign Keys on all tables
Alter Table FactWeather Add Constraint
	FK_FactWeather_DimEvents Foreign Key( [EventKey] ) 
	References dbo.DimEvents ( [EventKey] ) 
Go		
	
