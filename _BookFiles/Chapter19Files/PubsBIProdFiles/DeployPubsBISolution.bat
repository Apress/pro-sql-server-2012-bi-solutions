REM DeployPubsBISolution

REM Restore the database backup
REM CD "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn"
REM SQLCMD.exe -S RSLaptop2\SQL2012 -E -i "\\RSLAPTOP2\PubsBIProdFiles\RestoreDWPubsSales.sql"
REM pause

REM Run the ETL process
REM CD C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn
REM DtExec.exe /FILE \\RSLAPTOP2\PubsBIProdFiles\ETLProcessForDWPubsSales.dtsx
REM pause


CD C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn
RS.exe -i \\RSLAPTOP2\PubsBIProdFiles\DeploySalesByTitles.rss -s https://rslaptop2/ReportServer/ReportServer -u Administrator -p sandar


pause

