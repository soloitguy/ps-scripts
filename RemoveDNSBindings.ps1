PARAM(
[Parameter(mandatory=$true)][string] $ResourceGroupName,
[Parameter(mandatory=$true)][string] $WebAppNames,
[Parameter(mandatory=$true)][string] $domainName,
[Parameter(mandatory=$true)][string] $dnsPrefix
)

$appArray = $WebAppNames.split(',')

ForEach ($webAppName in $appArray){
    $urlBinding = $dnsPrefix + "." + $domainName 
    $webApp = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $webAppName
    $webApp.Hostnames.Remove("$urlBinding")
    Set-AzureRmWebApp -Name $webAppName -HostNames  $webApp.HostNames -ResourceGroupName $ResourceGroupName
    $binding = Get-AzureRmWebAppSSLBinding -ResourceGroupName $ResourceGroupName -WebAppName $webApp.Name
    Remove-AzureRmWebAppSSLBinding -WebAppName $webApp.Name -ResourceGroupName $ResourceGroupName -Name $urlBinding -DeleteCertificate $true -Force
}