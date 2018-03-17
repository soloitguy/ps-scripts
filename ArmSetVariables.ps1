#
# ARM Template - Set Variables In VSO
#
# This script will loop through all outputs from ARM templates and set as variables
# in the build process.
#
# $ResourceGroupName
#     The resource group name to retrieve last deployment from
#
# $ParameterNamespace
#     The namespace you want set in your VSO variables. This will preceed all variables.
#
# Example:
#     If $ParameterNamespace is set to 'Azure' and you have an output called 'appUrl'
#     it would be set as $(Azure.appUrl) in VSO
#

Param(
   [Parameter(Mandatory=$true)] [String] $ResourceGroupName,
   [String] $ParameterNamespace = "Azure"
)

$Deployment = (Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName | Sort Timestamp -Descending | Select -First 1)

if(!$Deployment)
{
    throw "Resource Group Deployment could not be found for '$ResourceGroupName'."
}

$OutputParameters = $Deployment.Outputs

if(!$OutputParameters)
{
    throw "No output parameters could be found for the last deployment of '$ResourceGroupName'."
}

Foreach($item in $OutputParameters.Keys) {
    $VariableName = $ParameterNamespace + '.' + $item
    Write-Host "##vso[task.setvariable variable=$VariableName;]$($OutputParameters.Item($item).Value)"
}
