
$dbname = "UniCom_KernelZone"
$dblog = "UniCom_KernelZone_log"
$fullbkupfile = "\\server\tcbuild$\Testers\DB\UniCom\UniCom_KernelZone.bak"
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

$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$dbname", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf")
$RelocateLog  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$dblog", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.ldf")
Restore-SqlDatabase -ServerInstance $env:COMPUTERNAME -Database $dbname -BackupFile  $fullbkupfile -RelocateFile @($RelocateData,$RelocateLog) -ReplaceDatabase
