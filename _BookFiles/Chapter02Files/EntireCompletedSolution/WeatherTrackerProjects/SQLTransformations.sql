
-- Convert the a data string to datetime
Declare @Date Char(11)
Set @Date = '1/23/2011'
Select @Date; -- Outcome = 1/23/2011
Select Convert(datetime, @Date) -- Outcome = 2011-01-23 00:00:00.0

-- Clear Tables
Delete From dbo.WeatherHistoryStaging
Delete From dbo.FactWeather
Delete From dbo.DimEvents

-- Get Dimension data from staging table
Select
  [Events]
From dbo.WeatherHistoryStaging

-- Get Fact data from staging table
Select
  [Date] = Convert(datetime, WHS.[Date])
, [Max TemperatureF]
, [Min TemperatureF]
, [EventKey]
From dbo.WeatherHistoryStaging as WHS
Join dbo.DimEvents as DE
	On WHS.[Events] = DE.[EventName]

	