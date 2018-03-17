PARAM(
[Parameter(Mandatory=$true)][string] $StorageAccountName,
[Parameter(Mandatory=$true)][string] $ResourceGroupName,
[Parameter(Mandatory=$true)][string] $ContainerName
)

  $StorageAccountKey = Get-AzureRMStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName
  $Ctx = New-AzureStorageContext $StorageAccountName -StorageAccountKey ($StorageAccountKey.Value -split '\n')[0]

Set-AzureStorageContainerAcl -Name $ContainerName -Permission Blob -PassThru -Context $Ctx

