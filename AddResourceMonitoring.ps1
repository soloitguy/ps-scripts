PARAM(
[Parameter(Mandatory=$true)][string]$omsResourceGroup,
[Parameter(Mandatory=$true)][string]$omsWorkspace,
[Parameter(Mandatory=$true)][string]$appResourceGroup
)

#Grab the OMS Workspace
$workspaceId = Get-AzureRMResource -ResourceGroup $omsResourceGroup -ResourceName $omsWorkspace

#Get the resources for monitoring
$resourcesForMonitoring = @()
$webSites = Get-AzureRMResource -ResourceGroupName $appResourceGroup -ResourceType Microsoft.Web/sites
$serverFarms = Get-AzureRMResource -ResourceGroupName $appResourceGroup -ResourceType Microsoft.Web/serverFarms
$databases = Get-AzureRMResource -ResourceGroupName $appResourceGroup -ResourceType Microsoft.Sql/servers/databases

$resourcesForMonitoring = $webSites + $serverFarms + $databases

#Enable monitoring on each resource
ForEach($resource in $resourcesForMonitoring) 
{
    try
    {
        Set-AzureRmDiagnosticSetting -ResourceId $resource.ResourceID -WorkspaceId $workspaceId.ResourceId -Enabled $true -ErrorAction "Stop"
        Write-Host "Added" $resource.ResourceName "to" $workspaceId.ResourceName
    }
    catch
    {
         Write-Host "!!!!!!" $resource.ResourceName "WAS NOT Added to" $workspaceId.ResourceName "!!!!!!"
    }
}