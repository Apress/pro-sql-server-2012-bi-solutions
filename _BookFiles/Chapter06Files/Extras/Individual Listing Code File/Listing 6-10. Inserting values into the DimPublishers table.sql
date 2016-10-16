-- Listing 6-10. Inserting values into the DimPublishers table

Insert  Into [DWPubsSales].[dbo].[DimPublishers]
( [PublisherId], [PublisherName] )
Select
  [PublisherId] = Cast( [pub_id] as nchar(4) )
   , [PublisherName] = Cast( [pub_name] as nvarchar(50) )
From [pubs].[dbo].[publishers]
