
function Format-Json {
    <#
    .SYNOPSIS
        Prettifies JSON output.
    .DESCRIPTION
        Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    .PARAMETER Json
        Required: [string] The JSON text to prettify.
    .PARAMETER Minify
        Optional: Returns the json string compressed.
    .PARAMETER Indentation
        Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
        Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .EXAMPLE
        $json | ConvertTo-Json  | Format-Json -Indentation 2
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character, 
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0)
            }

            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

            # If the line contains a [ or { character, 
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation
            }

            $line
        }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}


$dbname = "UniCom_Kernel"
$KillConnectionsSql="
			USE master
            IF EXISTS(select * from sys.databases where name='"+$dbname+"')
            BEGIN
				EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'"+$dbname+"'
			    ALTER DATABASE [$dbname] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
			    DROP DATABASE [$dbname]
			END;
			"
## Дропаем старую БД $dbname
Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction Continue
# Разворачиваем базу $dbname  
$fullbkupfile = "\\server\tcbuild$\Testers\DB\BaltBetM.original.bak"
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("BaltBetM", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf")
$RelocateData2  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("CoefFileGroup", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CoefFileGroup_$dbname.mdf")
$RelocateLog  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("BaltBet", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.ldf")
Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $dbname -BackupFile  $fullbkupfile -RelocateFile @($RelocateData,$RelocateData2,$RelocateLog) -ReplaceDatabase
$file = "\\server\tcbuild$\Testers\_VM Update Instructions\Jenkins\Test env deploy\UniCom.sql"
# Накатываем скрипты актуализации
Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Database $dbname -InputFile $file -ErrorAction Stop
$sql_command = 
"
CREATE TABLE [dbo].[BetStatuses] (
   [BetStatusId] INT NOT NULL,
   [BetId] INT NOT NULL,
   [BetStatus] INT NOT NULL,
   [WorkerId] INT NOT NULL,
   [CreationTime] DATETIME NOT NULL,
   [DeletionTime] DATETIME NULL
);
GO
ALTER TABLE [dbo].[BetStatuses]
ADD CONSTRAINT [PK_BetStatuses] PRIMARY KEY CLUSTERED ([BetStatusId] ASC);
"
Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Database $dbname -query $sql_command -ErrorAction Stop




#Блочная замени XML
(Get-Content -Raw -Path  C:\Kernel\Kernel.exe.config) -Replace "localhost" ,(Get-NetIPAddress -AddressFamily IPv4 |Where-Object InterfaceIndex -ne 1).IPAddress |set-content  C:\Kernel\Kernel.exe.config
(Get-Content -Raw -Path  C:\Kernel\Kernel.exe.config) -Replace "(?ms)<behavior name=""CpsBehavior"">\s*\r\n\s*<GlobalLogBehavior\s*/>" ,@"
<behavior name="CpsBehavior">
          <GlobalLogBehavior/>
            <clientCredentials>
              <clientCertificate findValue="/client/test.kernel" storeLocation="LocalMachine" x509FindType="FindBySubjectName"/>
              <serviceCertificate>
                <authentication certificateValidationMode="None" revocationMode="NoCheck"/>
              </serviceCertificate>
            </clientCredentials>
"@|set-content  C:\Kernel\Kernel.exe.config
(Get-Content -Raw -Path  C:\Kernel\Kernel.exe.config) -replace "<behavior name=""KernelTrackerServiceEndpointBehavior"">",@"
<behavior name="KernelTrackerServiceEndpointBehavior">
          <clientCredentials>
            <clientCertificate findValue="baltbet.com" storeLocation="LocalMachine" x509FindType="FindBySubjectName"/>
            <serviceCertificate>
              <authentication certificateValidationMode="None" revocationMode="NoCheck"/>
            </serviceCertificate>
          </clientCredentials>
"@|set-content  C:\Kernel\Kernel.exe.config
(Get-Content -Raw -Path  C:\Kernel\Kernel.exe.config) -replace '<behavior name="PaymentAggregatorBehavior">', @"
<behavior name="PaymentAggregatorBehavior">
          <clientCredentials>
            <clientCertificate findValue="/client/test.kernel" storeLocation="LocalMachine" x509FindType="FindBySubjectName"/>
            <serviceCertificate>
              <authentication certificateValidationMode="None" revocationMode="NoCheck"/>
            </serviceCertificate>
          </clientCredentials>
"@|set-content  C:\Kernel\Kernel.exe.config
(Get-Content -Raw -Path  C:\Kernel\Kernel.exe.config) -Replace "(?ms)<behavior name=""wcfSecureServiceBehavior"">\s*\r\n.*<GlobalLogBehavior\s*/>" ,@"
<behavior name="wcfSecureServiceBehavior">
          <serviceAuthorization principalPermissionMode="Custom">
            <authorizationPolicies>
              <add policyType="Kernel.Services.Wcf.UniAuthPolicy, Kernel"/>
            </authorizationPolicies>
          </serviceAuthorization>
          <GlobalLogBehavior/>
          <serviceCredentials>
            <serviceCertificate findValue="test.wcf.host" x509FindType="FindBySubjectName"/>
          </serviceCredentials>
"@|set-content  C:\Kernel\Kernel.exe.config
(Get-Content -Raw -Path  C:\Kernel\Kernel.exe.config) -Replace "(?ms)<binding name=""uniSecureNetTcpBinding"" .*>\s*\r\n\s*<security mode=""None""/>" ,@"
<binding name="uniSecureNetTcpBinding" maxConnections="200" listenBacklog="200" maxReceivedMessageSize="2147483647">
          <security mode="Transport">
            <transport clientCredentialType="None" protectionLevel="EncryptAndSign" sslProtocols="Tls12"/>
          </security>
"@|set-content  C:\Kernel\Kernel.exe.config
###
#XML values replace
####
$webConfig = "C:\Kernel\Kernel.exe.config"
$kerneldoc = [Xml](Get-Content $webConfig)
#edit configuration.appSettings.IdentificationServiceAddress value
$obj = $kerneldoc.configuration.appSettings.add | where {$_.Key -eq 'IdentificationServiceAddress' }
$obj.value = "http://localhost:8123"
$obj = $kerneldoc.configuration.appSettings.add | where {$_.Key -eq 'RabbitMQConnectionString' }
$obj.value = "host=localhost"
$obj = $kerneldoc.configuration.'system.serviceModel'.client.endpoint | where {$_.name -eq 'BasicHttpBinding_IServiceLoto' }
$obj.address = "http://localhost:8099/"
$obj = $kerneldoc.configuration.'system.serviceModel'.client.endpoint | where {$_.name -eq 'Default' }
$obj.address = "http://localhost:9011/"
$obj = $kerneldoc.configuration.'system.serviceModel'.client.endpoint | where {$_.name -eq 'Experimental' }
$obj.address = "http://localhost:9012/"
$obj = $kerneldoc.configuration.'system.serviceModel'.client.endpoint | where {$_.name -eq 'Bet365' }
$obj.address = "http://localhost:9013/"
$obj = $kerneldoc.configuration.'system.serviceModel'.client.endpoint | where {$_.name -eq 'CpsRegistrationServiceEndPoint' }
$obj.binding = "basicHttpBinding"
$obj.RemoveAttribute("bindingConfiguration")
$obj.RemoveAttribute("behaviorConfiguration")
$obj = $kerneldoc.configuration.connectionStrings.add | where {$_.name -eq 'kernelDb' }
$obj.connectionString = "server=localhost;Integrated Security=SSPI;MultipleActiveResultSets=true;Initial Catalog=$dbname;"
$obj = $kerneldoc.configuration.connectionStrings.add | where {$_.name -eq 'TimeBookingApi' }
$obj.connectionString = "http://localhost:63298"
$obj = $kerneldoc.configuration.connectionStrings.add | where {$_.name -eq 'Redis' }
$obj.connectionString = "localhost,connectTimeout=15000,syncTimeout=15000,asyncTimeout=15000"
$kerneldoc.Save($webConfig)
##open conf
$webConfig = "C:\Kernel\settings.xml"
$kerneldoc = [Xml](Get-Content -Raw -Path  $webConfig)
$obj = $kerneldoc.Settings.UniComClients.UniComClient | where {$_.Name -match "Commands" }
$obj.Host = "localhost"
$obj.Port = "5014"
$obj.ClientId = "7774"
$obj = $kerneldoc.Settings.UniComClients.UniComClient | where {$_.Name -match "Accounts" }
$obj.Host = "localhost"
$obj.Port = "5006"
$obj.ClientId = "7774"
$kerneldoc.Save($webConfig)



$xmlConfig = "C:\Kernel\settings.xml"
$settingsdoc = [Xml](Get-Content $xmlConfig)
$settingsdoc.Settings.ConnectionString = "server=localhost;Integrated Security=SSPI;MultipleActiveResultSets=true;Initial Catalog=$dbname"
$obj = $settingsdoc.Settings.EventCacheSettings
$obj.RestoreCoefsMode = "FromDb"
$obj = $settingsdoc.Settings.ConnectionString

$settingsdoc.Save($xmlConfig)


$pathtojson = "C:\Kernel\appsettings.json "
$json_appsetings = Get-Content -Raw -path $pathtojson | ConvertFrom-Json 
$HttpsInlineCertStore = '
    {
        "Url": "https://+:9081",
        "Certificate": {
          "Subject": "localhost",
          "Store": "My",
          "Location": "LocalMachine",
          "AllowInvalid": "true"
        }
     }
'| ConvertFrom-Json 
$json_appsetings.Kestrel.EndPoints.HttpsInlineCertStore =  $HttpsInlineCertStore
ConvertTo-Json $json_appsetings -Depth 4  | Format-Json | Set-Content $pathtojson -Encoding UTF8