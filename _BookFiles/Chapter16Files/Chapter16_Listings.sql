/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 16
*******************************************************/

-- Listing 16-1. XML Code in a Typical RDS Data Source File
/*

<?xml version="1.0" encoding="utf-8"?>
<RptDataSource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Name="DWPubsSalesDataSource">
  <ConnectionProperties>
    <Extension>SQL</Extension>
    <ConnectString>Data Source=RSLAPTOP2\SQL2012;Initial Catalog=DWPubsSales</ConnectString>
    <IntegratedSecurity>true</IntegratedSecurity>
  </ConnectionProperties>
  <DataSourceID>e54393b4-108f-4798-ad55-353a30c1e6e0</DataSourceID>
</RptDataSource>

*/


-- Listing 16-2. XML Code in a Typical RSD Dataset File
/*

<?xml version="1.0" encoding="utf-8"?>
<SharedDataSet xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner" xmlns="http://schemas.microsoft.com/sqlserver/reporting/2010/01/shareddatasetdefinition">
  <DataSet Name="">
    <Query>
      <DataSourceReference>DWPubsSalesDataSource</DataSourceReference>
      <CommandText>SELECT    
    PublisherName 
  , [Title] 
  , [TitleId] 
  , [OrderDate] 
  , [Total for that Date by Title]
 FROM vQuantitiesByTitleAndDate
</CommandText>
    </Query>
    <Fields>
      <Field Name="PublisherName">
        <DataField>PublisherName</DataField>
        <rd:TypeName>System.String</rd:TypeName>
      </Field>
      <Field Name="Title">
        <DataField>Title</DataField>
        <rd:TypeName>System.String</rd:TypeName>
      </Field>
      <Field Name="TitleId">
        <DataField>TitleId</DataField>
        <rd:TypeName>System.String</rd:TypeName>
      </Field>
      <Field Name="OrderDate">
        <DataField>OrderDate</DataField>
        <rd:TypeName>System.String</rd:TypeName>
      </Field>
      <Field Name="Total_for_that_Date_by_Title">
        <DataField>Total for that Date by Title</DataField>
        <rd:TypeName>System.Int32</rd:TypeName>
      </Field>
    </Fields>
  </DataSet>
</SharedDataSet>

*/


-- Listing 16-3. SQL Code for the DatasetvQuantitiesByTitleAndDateDataset
SELECT    
    PublisherName 
  , [Title] 
  , [TitleId] 
  , [OrderDate] 
  , [Total for that Date by Title]
 FROM vQuantitiesByTitleAndDate
