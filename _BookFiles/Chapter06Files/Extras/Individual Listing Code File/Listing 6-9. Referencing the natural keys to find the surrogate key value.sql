-- Listing 6-9. Referencing the natural keys to find the surrogate key value

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
