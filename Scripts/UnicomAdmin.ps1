
$dbname = 'UniCom_Administration'
$dblog = 'UniCom_Administration_log'
$fullbkupfile = "\\server\tcbuild$\Testers\DB\UniCom\UniCom_Administration.bak"

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
Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction Continue

$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$dbname", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf")
$RelocateLog  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$dblog", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.ldf")
Restore-SqlDatabase -ServerInstance $env:COMPUTERNAME -Database $dbname -BackupFile  $fullbkupfile -RelocateFile @($RelocateData,$RelocateLog) -ReplaceDatabase



$edit_settings_q = 
"
update [UniCom_Administration].Settings.SiteOptions set Value = case Name 
	when 'Global.WcfClient.PpsClientId' then case GroupId when 3 then '7774' else Value end
	when 'Global.RabbitMq.AccountBus.Exchange' then 'Exchange.AccountNotifications.UniComAz'
	when 'Registration.IsEnabled' then 'true'
	when 'Registration.InSessionDataEncrptionPassphrase' then 'true'
	when 'Login.IsEnabled' then 'true'
	when 'Global.WcfClient.WcfServicesHostAddress' then 'localhost'
	when 'Login.LoginUrl' then '/account/login'
	when 'Login.LoginUrl' then '/account/login'
	when 'OAuth.IsEnabled' then 'true'
	when 'OAuth.TokenUrl' then 'https://localhost/oauth/token'
	when 'OAuth.UniClient.Id' then 'owner'
	when 'OAuth.UniClient.Secret' then 'pwd'
	when 'GrpcClients.AccountDataClient.Port' then '32417'
	when 'GrpcClients.IdentificationServiceClient.Port' then '32417'
	when 'GrpcClients.PromocodeServiceClient.Port' then '32417'
	when 'GrpcClients.RegionAccountDataClient.Port' then '5007'
	when 'GrpcClients.BetProcessorClient.Port' then '5002'
	when 'GrpcClients.BetDataClient.Port' then '5008'
	when 'GrpcClients.ResultsDataClient.Port' then '5008'
	when 'GrpcClients.RegistrationServiceClient.Port' then '5025'
	else Value end
"
Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Query $edit_settings_q -ErrorAction Continue