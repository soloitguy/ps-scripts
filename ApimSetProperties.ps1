#
# API Management - SetProperties
#
# This script will set a property in API Management by either creating a new property
# or overwriting one that currently exists
#
# $ApiServiceName
#     The name of the API Management instance
#
# $Properties
#     A hash array of properties that will be set in APIM as key/value pairs
#

Param(
   [Parameter(Mandatory=$true)] [String] $ApiServiceName,
   [Parameter(Mandatory=$true)] [string[]] $Properties
)

$PropertiesArray = ConvertFrom-StringData ($Properties | out-string)

$ApiMgmtInstance = (Get-AzureRmApiManagement | Where-Object { $_.Name -eq $ApiServiceName })

if(!$ApiMgmtInstance)
{
    throw "Api Management Instance $ApiServiceName cannot be found"
}

$Context = New-AzureRmApiManagementContext -ResourceGroupName $ApiMgmtInstance.ResourceGroupName -ServiceName $ApiMgmtInstance.Name

foreach($Property in $PropertiesArray.Keys) {
    $PropertyExists = (Get-AzureRmApiManagementProperty -Context $Context -Name $Property)

    if($PropertyExists) {
        Set-AzureRmApiManagementProperty -Context $Context -Name $Property -Value $PropertiesArray.Item($Property) -PropertyId $PropertyExists.PropertyId
        Write-Output "API Property Set: $Property"
    } else {
        New-AzureRmApiManagementProperty -Context $Context -Name $Property -Value $PropertiesArray.Item($Property)
    }
}
