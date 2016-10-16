-- Listing 6-27. Executing a stored procedure with a parameter
Declare @TodaysDate datetime 
Set @TodaysDate =  Cast( GetDate() as datetime )
Execute pEtlFactSalesData 
  @OrderDate = @TodaysDate
