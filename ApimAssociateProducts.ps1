#
# API Management - AssociateProducts
#
# Associate a list of products with the API that is being deployed.
#
# $ApiServiceName
#     The name of the API Management instance.
#
# $ApiName
#     Provide name for API when creating/updating.
#
# $Products
#     An array of product names that need to be associated with the API.
#

Param(
    [Parameter(Mandatory=$true)] [string] $ApiServiceName,
    [Parameter(Mandatory=$true)] [string] $ApiId,
    [Parameter(Mandatory=$true)] [array] $Products
)

$ApiMgmtInstance = (Get-AzureRmApiManagement | Where-Object { $_.Name -eq $ApiServiceName })

if(!$ApiMgmtInstance)
{
    throw "Api Management Instance $ApiServiceName cannot be found"
}

$Context = New-AzureRmApiManagementContext -ResourceGroupName $ApiMgmtInstance.ResourceGroupName -ServiceName $ApiMgmtInstance.Name

foreach($Product in $Products) {
    $ProductObject = Get-AzureRmApiManagementProduct -Context $Context -Title $Product

    if(!$ProductObject)
    {
        throw "Product $Product could not be found"
    }
    
    Add-AzureRmApiManagementApiToProduct -Context $Context -ApiId $ApiId -ProductId $ProductObject.ProductId
}
