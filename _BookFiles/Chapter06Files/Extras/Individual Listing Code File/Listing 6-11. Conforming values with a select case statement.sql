-- Listing 6-11. Conforming values with a select–case statement
Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'					 
      When 'psychology' Then 'Psychology'						 
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     
    End
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
