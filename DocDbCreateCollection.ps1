#
# DocumentDB - Create Database & Collection
#
# Deploy a database and collections from a parameter file
#
# $accountEndpoint
#     The full endpoint without the port
#
# $connectionKey
#     The master connection key for authorization
#
# $paramFile
#     Param file that includes database information, collection information and throughput for
#     collections.
#
# Example Param File:
# {
#   "name": "test",
#   "collections": [
#      {
#        "name": "collection_one",
#        "throughput": 400
#      },
#      {
#        "name": "collection_two",
#        "throughput": 600
#      }
#   ]
# }
#

param
(
    [Parameter(Mandatory=$true)] [string]$accountEndpoint,
    [Parameter(Mandatory=$true)] [string]$connectionKey,
    [Parameter(Mandatory=$true)] [string]$paramFile
)

. $PSScriptRoot\DocDbHelpers.ps1

#
# Load Meta File
#
$Meta = (Get-Content $paramFile) | ConvertFrom-Json

if(!$Meta) {
    throw "Meta file cannot be loaded, cannot continue"
}

$DatabaseName = $Meta.name
$Collections = $Meta.collections

#
# Create Database/Check For Database
#
$db = GetDatabases -rootUri $accountEndpoint -key $connectionKey | where { $_.id -eq $DatabaseName }

if ($db -ne $null) {
    Write-Host "Database already exists"
} else {
    $newDb = CreateDatabase -rootUri $accountEndpoint -key $connectionKey -dbname $databaseName
}

#
# Create Collections
#
foreach($Collection in $Collections) {
    $coll = GetCollections -rootUri $accountEndpoint -key $connectionKey -dbname $databaseName | where { $_.id -eq $Collection.name }

    if ($coll -ne $null) {
        Write-Host "Collection already exists"
    } else {
        $newColl = CreateCollection -rootUri $accountEndpoint -key $connectionKey -dbname $DatabaseName -collName $Collection.name -throughput $Collection.throughput
    }
}