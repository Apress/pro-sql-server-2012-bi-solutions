/********** Pro SQL Server 2012 BI Solutions **********
This file contains the listing code found in chapter 19
*******************************************************/


-- Listing 19-1. Restoring a SQL Server Backup File from a Network Share

-- Check to see if they already have a database with this name...
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DWPubsSales')
  BEGIN
  -- If they do, they need to close connections to the DWPubsSales database, with this code!
    ALTER DATABASE [DWPubsSales] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  END

-- Now now restore the Empty database...
USE Master 
RESTORE DATABASE [DWPubsSales] 
FROM DISK = N'\\RSLAPTOP2\PubsBIProdFiles\DWPubsSales_BeforeETL.bak'
WITH REPLACE
GO

-- Listing 19-2. Executing a SQL File from a Network Share
/*
CD "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn"
SQLCMD.exe -S RSLaptop2\SQL2012 -E -i \\RSLAPTOP2\PubsBIProdFiles\RestoreDWPubsSales.sql

Listing 19-3. Executing an SSIS File from a Network Share
CD C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn
DtExec.exe /FILE \\RSLAPTOP2\PubsBIProdFiles\ETLProcessForDWPubsSales.dtsx
*/

-- Listing 19-4. Combining Multiple Commands into a Batch File
/*

REM DeployPubsBISolution

REM Restore the database backup
CD "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn"
SQLCMD.exe -S RSLaptop2\SQL2012 -E -i "\\RSLAPTOP2\PubsBIProdFiles\RestoreDWPubsSales.sql"
pause

REM Run the ETL process
CD C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn
DtExec.exe /FILE \\RSLAPTOP2\PubsBIProdFiles\ETLProcessForDWPubsSales.dtsx
pause

*/


-- Listing 19-5. XMLA Code to Restore an SSAS Database
/*

<Restore xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
  <File>\\RSLAPTOP2\PubsBIProdFiles\PubsBICubes.abf</File>
  <DatabaseName>PubsBICubes</DatabaseName>
  <AllowOverwrite>true</AllowOverwrite>
  <Security>IgnoreSecurity</Security>
</Restore>

*/

-- Listing 19-6. Executing the SSIS Package to Restore an SSAS Database
/*

CD C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn
DtExec.exe /FILE \\RSLAPTOP2\PubsBIProdFiles\RestorePubsBICubes.dtsx

*/

-- Listing 19-7. Code to Place in an .rss File to Upload an SSRS Report
/*

' Deploy SSRS Report from a Command Line: 
' RS.exe -i deploy_report.rss -s http://rslaptop2/ReportServer_SQL2012/ReportServer
'

Dim strPath = "\\RSLAPTOP2\PubsBIProdFiles\"
Dim strReportName = "SalesByTitles"
Dim strWebSiteFolder = "/PubsBIReport"

Dim arrRDLCode As [Byte]() = Nothing
Dim arrWarnings As Warning() = Nothing
Public Sub Main()
    Try
     'Read the RDL code out of the file.
     Dim stream As FileStream = File.OpenRead(strPath + strReportName + ".rdl")
     arrRDLCode = New [Byte](stream.Length) {}
     stream.Read(arrRDLCode, 0, CInt(stream.Length))
     stream.Close()

     'Upload the RDL code to the Web Service
     arrWarnings = rs.CreateReport(strReportName, strWebSiteFolder, True, arrRDLCode, Nothing)
     If Not (arrWarnings Is Nothing) Then
         Dim objWarning As Warning
         For Each objWarning In arrWarnings
             Console.WriteLine(objWarning.Message)
         Next objWarning
     Else
         Console.WriteLine("Report: {0} published successfully with no warnings", REPORT)
     End If
    Catch e As IOException
     Console.WriteLine(e.Message)
    End Try
End Sub

*/


-- Listing 19-8. Code to Place in an .rss File to Upload an SSRS Report
/*

CD C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn

RS.exe -i \\RSLAPTOP2\PubsBIProdFiles\DeploySalesByTitles.rss 
-s https://rslaptop2/ReportServer/ReportServer

*/