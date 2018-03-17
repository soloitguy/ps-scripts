PARAM(
[Parameter(Mandatory=$false)][string] $funcResourceGroup,
[Parameter(Mandatory=$false)][string] $funcNames,
[Parameter(Mandatory=$false)][string] $jsonFile,
[Parameter(Mandatory=$false)][string] $VaultName
)

if([string]::IsNullOrWhiteSpace($jsonFile) -Or [string]::IsNullOrWhiteSpace($funcResourceGroup) -Or [string]::IsNullOrWhiteSpace($funcNames))
{
    #exiting as the calling release calls this script, but does not require it, so it will pass a null param file, and we won't run.
    exit
}

$funcArray = $funcNames.split(',')

$newSettings = Get-Content $jsonFile | ConvertFrom-Json

ForEach($setting in $newSettings)
{
    if($setting.name.ToString() -like "*ClientSecret*")
    {
        $clientSecret = Get-AzureKeyVaultSecret -VaultName $VaultName -Name $setting.value.ToString()
        $setting.value = $clientSecret.SecretValueText
    }
}

$resourceNumber = 0;
ForEach ($func in $funcArray){

    # This following if statement is a hack for handling "Change station auto approval function to use configurable cron expression" 
    # so that queued auto-approvals trigger on different schedules
    if($resourceNumber -gt 0)
    {
        ForEach($setting in $newSettings)
        {
            if($setting.name.ToString() -eq "AutoApprovalSchedule")
            {
                $setting.value = "0 0-58/2 * * * *"
            }
        }
    }
$funcApp = Get-AzureRmWebApp -ResourceGroupName $funcResourceGroup -Name $func
$funcAppSettings = $funcApp.SiteConfig.AppSettings
$funcAppSettings += $newSettings
$ht=@{}
$funcAppSettings.syncroot | Foreach { $ht[$_.Name] = $_.Value }
Set-AzureRMWebApp -ResourceGroupName $funcResourceGroup -Name $func -AppSettings $ht

$resourceNumber += 1
}
