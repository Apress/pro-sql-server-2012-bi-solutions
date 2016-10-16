-- Listing 6-28. Creating a User Defined Function 
Create Function fEtlTransformStateToLongName 
  ( @StateAbbreviation nChar(2) )
  Returns nVarchar(50)
As
  Begin 
    Return  
    ( Select Case @StateAbbreviation
        When 'CA' Then 'California'
        When 'OR' Then 'Oregon'    
        When 'WA' Then 'Washington'           
     End )
  End
