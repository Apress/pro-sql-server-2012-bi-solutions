-- Listing 6-16. Converting null values with the IsNull function 
Select 
    [TitleId] = Cast( isNull( [title_id], -1 ) as nvarchar(6) )
  , [TitleName] = Cast( isNull( [title], 'Unknown' ) as nvarchar(50) )
  , [TitleType] = Cast( isNull( [type], 'Unknown' ) as nvarchar(50) )
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( isNull( [price], -1 ) as decimal(18, 4) )
  , [PublishedDate] = isNull( [pubdate], '01/01/1900' ) 
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
	On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
