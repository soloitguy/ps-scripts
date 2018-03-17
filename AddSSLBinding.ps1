##############################################################################################################################################
#                                                                                                                                            
# PS Script Description: Add Topics and Subscriptions to Existing Party ServiceBus, if they do not exist.                                    
#                                                                                                                                            
# This script will iterate through a list of WebApps and create SSL Bindings for each with the supplied Azure KeyVault Certificate           
# $ResourceGroupName                                                                                                         
#    Resource Group Name of the WebApp
# $WebAppNames
#    Comma Delimited List of WebAppNames (ex: app-dev-nucleus-connect0,app-dev-nucleus-connect1)
# $certName
#    Name of the Azure KeyVault Certificate (ex: hdp-amerisourcebergen-com)
# $vaultName
#    Name of the Azure KeyVault (ex: psg-cp-dev-arm-keyvault)
# $wildcard
#    Wildcard Base URL (ex: hdp.amerisourcebergen.com)
# $dnsPrefix
#    Prefix for the App (ex: identity.dev)
#
##############################################################################################################################################




PARAM(
[Parameter(mandatory=$true)][string] $ResourceGroupName,
[Parameter(mandatory=$true)][string] $WebAppNames,
[Parameter(mandatory=$true)][string] $certName,
[Parameter(mandatory=$true)][string] $vaultName,
[Parameter(mandatory=$true)][string] $wildcard,
[Parameter(mandatory=$true)][string] $dnsPrefix
)


$cert =  Get-AzureKeyVaultCertificate -VaultName $vaultName -Name $certName
$appArray = $WebAppNames.split(',')

ForEach ($app in $appArray){
    $appPrefix = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $app
    $bindingExists = Get-AzureRmWebAppSSLBinding -ResourceGroupName $ResourceGroupName -WebAppName $appPrefix.Name
If (!$bindingExists){
    $urlBinding = $dnsPrefix + "." + $wildcard
    $vault = Get-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName psg-management
    $vaultId = $vault.ResourceId
    $appId = $appPrefix.Name
    Write-Host "Creating Custom HostName $urlBinding"
    Set-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $appPrefix.Name -HostNames $urlBinding -WarningAction SilentlyContinue
    
    Write-Host "Creating Web App Certificate $appId-cert"
    New-AzureRmResource -Location $appPrefix.Location -Properties @{"keyVaultId" = "$vaultId"; "keyVaultSecretName" = "$certName"} -ResourceName "$appId-cert" -ResourceType "microsoft.web/certificates" -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue  -Force
    
    Write-Host "Creating SSL binding to $urlBinding"
    New-AzureRmWebAppSSLBinding -ResourceGroupName $ResourceGroupName -WebAppName $appPrefix.Name -Thumbprint $cert.Thumbprint -Name $urlBinding -SslState SniEnabled
}
Else {
    Write-Host "This Binding already exists"
     }
}

    

