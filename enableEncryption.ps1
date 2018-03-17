$accounts = Find-AzureRmResource -ResourceType Microsoft.Storage/storageAccounts
foreach ($account in $accounts) {
    Set-AzureRmStorageAccount -ResourceGroupName $account.ResourceGroupName -AccountName $account.Name -EnableEncryptionService "Blob" -StorageEncryption -Verbose
    Write-Host $account.Name  "is now encrypted" in $account.ResourceGroupName
    }

