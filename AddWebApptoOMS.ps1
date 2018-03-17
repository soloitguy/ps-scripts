PARAM(
[Parameter(Mandatory=$true)][string]$omsResourceGroup,
[Parameter(Mandatory=$true)][string]$omsWorkspace,
[Parameter(Mandatory=$true)][string]$appResourceGroup
)


$workspaceId = Get-AzureRMResource -ResourceGroup $omsResourceGroup -ResourceName $omsWorkspace
$apps = Get-AzureRMResource -ResourceGroupName $appResourceGroup -ResourceType Microsoft.Web/sites


ForEach($app in $apps) {
Set-AzureRmDiagnosticSetting -ResourceId $app.ResourceID -WorkspaceId $workspaceId.ResourceId -Enabled $true
Write-Host "Added" $app.ResourceName "to" $workspaceId.ResourceName
}


