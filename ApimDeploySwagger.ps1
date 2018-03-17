#
# API Management - DeploySwagger
#
# Deploy a swagger file from a remote URL, then commit this to the API Management
# git repository that is centrally located in the API Management service. When running
# in VSTS, a subscription should be assigned which will provide Azure context for locating
# the API Management service.
#
# $ApiServiceName
#     The name of the API Management instance.
#
# $ApiName
#     Provide name for API when creating/updating.
#
# $SwaggerUrl
#     The location of the swagger information to populate the API with.
#

Param(
    [Parameter(Mandatory=$true)] [string] $ApiServiceName,
    [Parameter(Mandatory=$true)] [string] $ApiName,
    [Parameter(Mandatory=$true)] [string] $SwaggerUrl
)

$ApiMgmtInstance = (Get-AzureRmApiManagement | Where-Object { $_.Name -eq $ApiServiceName })

if(!$ApiMgmtInstance)
{
    throw "Api Management Instance $ApiServiceName cannot be found"
}

$Context = New-AzureRmApiManagementContext -ResourceGroupName $ApiMgmtInstance.ResourceGroupName -ServiceName $ApiMgmtInstance.Name

$ImportStatus = Import-AzureRmApiManagementApi -Context $Context -SpecificationFormat Swagger -SpecificationUrl $SwaggerUrl -ApiId $ApiName -Path $ApiName

if(!$ImportStatus)
{
    throw "Api Management Could Not Import $SwaggerUrl"
}
