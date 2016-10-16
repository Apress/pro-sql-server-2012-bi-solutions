-- Listing 6-6. Selecting only data required for the destination table

Select 
    [title_id]
  , [title]
  , [type]
  , [pub_id]
  , [price]
  , [pubdate]
From [Pubs].[dbo].[Titles]
