#
# Retrieve Secret From KeyVault
#

Param(
   [Parameter(Mandatory=$true)] [String] $VaultName,
   [Parameter(Mandatory=$true)] [String] $SecretName,
   [Parameter(Mandatory=$true)] [String] $VariableName
)

$Secret = Get-AzureKeyVaultSecret -VaultName $VaultName -Name $SecretName
Write-Host "##vso[task.setvariable variable=$VariableName;]$($Secret.SecretValueText)"