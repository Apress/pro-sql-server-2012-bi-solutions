-- Listing 6-8. Using the function to convert data types

Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Cast( [type] as nvarchar(50) )
-- , [pub_id]  Will be replaced with a PublisherKey
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate] -- has the same data type in both tables
From [Pubs].[dbo].[Titles]
