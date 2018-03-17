Param(
    [Parameter(Mandatory=$true)] [string] $ApiServiceName,
    [Parameter(Mandatory=$true)] [string] $ApiName
)

$ApiMgmtInstance = (Get-AzureRmApiManagement | Where-Object { $_.Name -eq $ApiServiceName })

if(!$ApiMgmtInstance)
{
    throw "Api Management Instance $ApiServiceName cannot be found"
}

$Context = New-AzureRmApiManagementContext -ResourceGroupName $ApiMgmtInstance.ResourceGroupName -ServiceName $ApiMgmtInstance.Name

#Remove from APIM

$RemoveStatus = Remove-AzureRmApiManagementApi -Context $Context -ApiId $ApiName

if(!$RemoveStatus)
{
    throw "Could not remove $ApiName from API Management."
}
else 
{
    Write-Host "Removed $ApiName from $ApiServiceName"
}
