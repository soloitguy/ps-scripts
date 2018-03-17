PARAM(
 [Parameter(Mandatory=$true)] [String] $prefix,
 [Parameter(Mandatory=$true)] [String] $tfcmgrurl,
 [Parameter(Mandatory=$true)] [String] $domain
)

$recordExists = Get-AzureRmDnsRecordSet -ZoneName $domain -ResourceGroupName psg-management -Name $prefix -RecordType CNAME -ErrorAction SilentlyContinue

if(-not $recordExists){
  Write-Host "Creating CNAME for $prefix"
  New-AzureRmDnsRecordSet -Name $prefix -RecordType CNAME -ZoneName $domain -ResourceGroupName psg-management  -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig -Cname $tfcmgrurl)
}
else {
  Write-Host "$prefix Already Exists"
}