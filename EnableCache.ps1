PARAM(
[Parameter(mandatory=$true)][string] $appResourceGroup,
[Parameter(mandatory=$true)][string] $appNames
)
$appArray = $appNames.split(',')

ForEach ($appName in $appArray){

$webApp = Get-AzureRmWebApp -ResourceGroupName $appResourceGroup -Name $appName
$webAppSettings = $webApp.SiteConfig.AppSettings
$cacheHash = @{ "Value" = "Always"; "Name" = "WEBSITE_LOCAL_CACHE_OPTION"} | ConvertTo-Json | ConvertFrom-Json

$webAppSettings += $cacheHash
$newAppSettings = @{}

$webAppSettings | Foreach {$newAppSettings[$_.Name] = $_.Value}

Set-AzureRMWebApp -ResourceGroupName $appResourceGroup -Name $appName -AppSettings $newAppSettings -ErrorAction SilentlyContinue
}