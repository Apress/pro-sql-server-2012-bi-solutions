-- Listing 6-15. Excluding nulls with the Where clause 
Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] = Cast( [type] as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Where [Pubs].[dbo].[Titles].[Title_Id] Is Not Null
And [Pubs].[dbo].[Titles].[Title] Is Not Null
And [Pubs].[dbo].[Titles].[Type] Is Not Null
And [Pubs].[dbo].[Titles].[Price] Is Not Null
And [Pubs].[dbo].[Titles].[PubDate] Is Not Null
