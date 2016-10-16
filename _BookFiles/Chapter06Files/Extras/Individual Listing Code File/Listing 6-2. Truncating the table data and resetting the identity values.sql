-- Listing 6-2. Truncating the table data and resetting the identity values

/****** Drop Foreign Key s ******/
Alter Table [dbo].[DimTitles]  Drop Constraint [FK_DimTitles_DimPublishers] 
Alter Table [dbo].[FactTitlesAuthors] Drop Constraint [FK_FactTitlesAuthors_DimAuthors] 
Alter Table [dbo].[FactTitlesAuthors] Drop Constraint [FK_FactTitlesAuthors_DimTitles] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimStores] 
Alter Table [dbo].[FactSales] Drop Constraint [FK_FactSales_DimTitles] 
Go

/****** Clear all tables and reset their Identity Auto Number ******/
Truncate Table dbo.FactSales
Truncate Table dbo.FactTitlesAuthors
Truncate Table dbo.DimTitles
Truncate Table dbo.DimPublishers
Truncate Table dbo.DimStores
Truncate Table dbo.DimAuthors
Go

/****** Add Foreign Keys ******/
Alter Table [dbo].[DimTitles]  With Check Add Constraint [FK_DimTitles_DimPublishers] 
Foreign Key  ([PublisherKey]) References [dbo].[DimPublishers] ([PublisherKey])

Alter Table [dbo].[FactTitlesAuthors]  With Check Add Constraint [FK_FactTitlesAuthors_DimAuthors] 
Foreign Key  ([AuthorKey]) References [dbo].[DimAuthors] ([AuthorKey])

Alter Table [dbo].[FactTitlesAuthors]  With Check Add Constraint [FK_FactTitlesAuthors_DimTitles] 
Foreign Key ([TitleKey]) References [dbo].[DimTitles] ([TitleKey])

Alter Table [dbo].[FactSales]  With Check Add Constraint [FK_FactSales_DimStores] 
Foreign Key ([StoreKey]) References [dbo].[DimStores] ([Storekey])

Alter Table [dbo].[FactSales]  With Check Add Constraint [FK_FactSales_DimTitles] 
Foreign Key ([TitleKey]) References [dbo].[DimTitles] ([TitleKey])
Go
