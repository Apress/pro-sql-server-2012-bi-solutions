-- Listing 6-12. Conforming values with a lookup table
-- Create the lookup table
Create table [TitleTypeLookup] ( 
    [TitleTypeKey] int Primary Key Identity 
  , [OriginalTitleType] nvarchar(50)
  , [CleanTitleType] nvarchar(50)
)

-- Add the original and transformed data
Insert into [TitleTypeLookup]
  ( [OriginalTitleType] , [CleanTitleType] ) 
Select 
    [OriginalTitleType] = [Type]	
  , [CleanTitleType] = Case Cast( [type] as nvarchar(50) )
      When 'business' Then 'Business'
      When 'mod_cook' Then 'Modern Cooking'						     
      When 'popular_comp' Then 'Popular Computing'					 
      When 'psychology' Then 'Psychology'						 
      When 'trad_cook' Then 'Traditional Cooking'	
      When 'UNDECIDED' Then 'Undecided'							     
    End
From [Pubs].[dbo].[Titles]
Group By [Type]	-- get distinct values

-- Combine the data from the lookup table and the original table
Select 
    [TitleId] = Cast( [title_id] as nvarchar(6) )
  , [TitleName] = Cast( [title] as nvarchar(50) )
  , [TitleType] =  [CleanTitleType]
  , [PublisherKey] = [DWPubsSales].[dbo].[DimPublishers].[PublisherKey]
  , [TitlePrice] = Cast( [price] as decimal(18, 4) )
  , [PublishedDate] = [pubdate]
From [Pubs].[dbo].[Titles]
Join [DWPubsSales].[dbo].[DimPublishers]
  On [Pubs].[dbo].[Titles].[pub_id] = [DWPubsSales].[dbo].[DimPublishers].[PublisherId]
Join [DWPubsSales].[dbo].[TitleTypeLookup]
  On [Pubs].[dbo].[Titles].[type] =  [DWPubsSales].[dbo].[TitleTypeLookup].[OriginalTitleType]
