Param(
   [Parameter(Mandatory=$true)] [String] $resourceGroupName,
   [Parameter(Mandatory=$true)] [String] $serverName,
   [Parameter(Mandatory=$true)] [String] $BuildAgent
)

$agentIpAddress = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip

New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName $BuildAgent -StartIpAddress $agentIpAddress -EndIpAddress $agentIpAddress        

Write-Host "Firewall rule for $BuildAgent at $agentIpAddress has been added."