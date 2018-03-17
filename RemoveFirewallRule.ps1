Param(
   [Parameter(Mandatory=$true)] [String] $serverName,
   [Parameter(Mandatory=$true)] [String] $BuildAgent
)


Remove-AzureRmSqlServerFirewallRule -ServerName '$serverName' -FirewallRuleName "$BuildAgent" 

Write-Host "Firewall rule for $BuildAgent has been removed."