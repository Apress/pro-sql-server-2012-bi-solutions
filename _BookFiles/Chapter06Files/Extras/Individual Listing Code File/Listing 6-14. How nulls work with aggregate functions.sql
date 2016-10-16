-- Listing 6-14. How nulls work with aggregate functions 
-- Using a null you get the correct answer of 4
Select Avg([Amt]) From ( 
  Select [Amt] = 2
    Union 
  Select [Amt] = 6
    Union 
  Select [Amt] = null 
) as aDemoTableWithNull


-- Using a zero you get the incorrect answer of 2
Select Avg([Amt]) From ( 
  Select [Amt] = 2
    Union 
  Select [Amt] = 6
    Union 
  Select [Amt] = 0 
) as aDemoTableWithZero
