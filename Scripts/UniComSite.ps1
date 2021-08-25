$dbname = 'UniCom_Site'
$fullbkupfile = "\\server\tcbuild$\Testers\DB\UniCom\UniCom_Site.bak"

$KillConnectionsSql=
"
USE master
GO
ALTER DATABASE $dbname SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE master
GO
ALTER DATABASE $dbname SET MULTI_USER
GO
USE master
GO
"
Invoke-Sqlcmd -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction Continue

$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("Uniru", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf")
$RelocateLog  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("Uniru_log", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.ldf")
Restore-SqlDatabase -ServerInstance $env:COMPUTERNAME -Database $dbname -BackupFile  $fullbkupfile -RelocateFile @($RelocateData,$RelocateLog) -ReplaceDatabase
