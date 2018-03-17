#
# API Management - AssociateProducts
#
# Associate a list of products with the API that is being deployed.
#
# $ApiServiceName
#     The name of the API Management instance.
#

Param(
    [Parameter(Mandatory=$true)] [string] $ApiServiceName,
    [string] $GitBranch = "master"
)

$ApiMgmtInstance = (Get-AzureRmApiManagement | Where-Object { $_.Name -eq $ApiServiceName })

if(!$ApiMgmtInstance)
{
    throw "Api Management Instance $ApiServiceName cannot be found"
}

$Context = New-AzureRmApiManagementContext -ResourceGroupName $ApiMgmtInstance.ResourceGroupName -ServiceName $ApiMgmtInstance.Name

$SyncStatus = Get-AzureRmApiManagementTenantSyncState -Context $Context

if(-Not $SyncStatus.IsSynced) {
    Save-AzureRmApiManagementTenantGitConfiguration -Branch $GitBranch -Context $Context
}
