PARAM (
    # SQL Server URL
    [Parameter(Mandatory=$true)][string]$sqlURL,
    # Database Name
    [Parameter(Mandatory=$true)][string]$sqlIntDB,
    # SQL Admin Login
    [Parameter(Mandatory=$true)][string]$userId,
    # Password
    [Parameter(Mandatory=$true)][string]$sqlPassword
    
)

$connectionString = "Data Source=$sqlURL,1433;Initial Catalog=$sqlIntDB;User Id=$userId;Password=$sqlPassword;"
$appSettingsFile = Get-ChildItem -r | Where-Object {$_.Name -eq "appsettings.Development.json"} |  Get-Content -raw | ConvertFrom-Json
<#
$firstPart = $appSettingsFile.Abc
$secondPart = $firstPart.Absg.ConnectionStrings

$finalPart = $secondPart.IntegrationTestDb

$finalPart = $connectionString
$secondPart.IntegrationTestDb = $finalPart

$firstPart.Absg.ConnectionStrings = $secondPart

$appSettingsFile.Abc = $firstPart

$appSettingsFile | ConvertTo-Json -Depth 5 | Set-Content .\appsettings.Development.json 
#>

$appSettingsFile = Get-ChildItem | where {$_.Name -eq "appSettings.Development.json"} |  Get-Content -raw | ConvertFrom-Json -Verbose
$connString = $appSettingsFile.Abc.Absg.ConnectionStrings
$connString.IntegrationTestDb = $connectionString
$appSettingsFile.Abc.Absg.ConnectionStrings = $connString
$appSettingsFile | ConvertTo-Json -Depth 20 | Set-Content "./bin/release/netcoreapp1.1/appSettings.Development.json" -Verbose

cat "./bin/release/netcoreapp1.1/appSettings.Development.json"