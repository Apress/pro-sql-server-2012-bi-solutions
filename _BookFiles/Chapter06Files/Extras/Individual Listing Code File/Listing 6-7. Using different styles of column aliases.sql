-- Listing 6-7. Using different styles of column aliases

-- Older style column aliases: [column name] as [alias]
Select 
    [title_id] as [TitleId]
  , [title] as [TitleName] 
  , [type] as [TitleType] 
  --, [pub_id]  Will be replaced with a PublisherKey
  , [price] as [TitlePrice] 
  , [pubdate] as [PublishedDate] 
From [Pubs].[dbo].[Titles]

-- Newer style column aliases: [alias] = [column name]
Select 
    [TitleId] = [title_id]
  , [TitleName] = [title]
  , [TitleType] = [type]
  --, [pub_id]  Will be replaced with a PublisherKey
  , [TitlePrice] = [price]
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
