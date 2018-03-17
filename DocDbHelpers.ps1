
#
# Date
#
# Date generation is required for every request and when creating Authorization
# headers.
#
function GetUTDate() {
    $date = get-date
    $date = $date.ToUniversalTime();
    return $date.ToString("r", [System.Globalization.CultureInfo]::InvariantCulture);
}

#
# Generate Authorization Key
#
# DocumentDB requires a special token construction process to connect and manage
# the database. This will generate that key/token from all the required fields
#
# @link https://docs.microsoft.com/en-us/rest/api/documentdb/access-control-on-documentdb-resources
#
# $verb
#     The http verb we will use for our request. Exp: get|post|put|delete
#
# $resourceId
#     The resource ID of what we are trying to alter. Exp: dbs/mydb/colls/mycollection
#
# $resourceType
#     Resource type that we are trying to alter. Exp: dbs|colls|users
#
# $date
#     The date of the in universal time to generate key with
#
# $masterKey
#     The master key that is provided by the DocDB account
#
function GenerateKey([System.String]$verb = '',[System.String]$resourceId = '', [System.String]$resourceType = '',
    [System.String]$date = '',[System.String]$masterKey = '') {

    $keyBytes = [System.Convert]::FromBase64String($masterKey)
    $text = @($Verb.ToLowerInvariant() + "`n" + $ResourceType.ToLowerInvariant() + "`n" + $ResourceId + "`n" + $Date.ToLowerInvariant() + "`n" + "`n")
    $body =[Text.Encoding]::UTF8.GetBytes($text)
    $hmacsha = new-object -TypeName System.Security.Cryptography.HMACSHA256 -ArgumentList (,$keyBytes)
    $hash = $hmacsha.ComputeHash($body)
    $signature = [System.Convert]::ToBase64String($hash)

    [System.Net.WebUtility]::UrlEncode($('type=master&ver=1.0&sig=' + $signature))
}

#
# Build Headers
#
# Construct the headers that are required for all DocumentDB requests
#
# @link https://docs.microsoft.com/en-us/rest/api/documentdb/common-documentdb-rest-request-headers
#
# $action
#     The http verb we will use for our request. Exp: get|post|put|delete
#
# $resourceId
#     The resource ID of what we are trying to alter. Exp: dbs/mydb/colls/mycollection
#
# $resType
#     Resource type that we are trying to alter. Exp: dbs|colls|users
#
# $date
#     The date of the in universal time to generate key with
#
# $key
#     The master key that is provided by the DocDB account
#
function BuildHeaders([string]$action,[string]$resType, [string]$resourceId, [string]$date, [string]$key){
    $authz = GenerateKey -verb $action -resourceType $resType -resourceId $resourceId -date $date -masterKey $key
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $authz)
    $headers.Add("x-ms-version", '2015-12-16')
    $headers.Add("x-ms-date", $date)
    $headers
}

#
# Get Databases
#
# return all databases that exist in account
#
function GetDatabases([string]$rootUri, [string]$key) {
    $uri = $rootUri + "/dbs"
    $date = GetUTDate
    $hdr = BuildHeaders -action 'get' -resType dbs -date $date -key $key
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $hdr
    $response.Databases
    Write-Host ("Found " + $Response.Databases.Count + " Database(s)")
}

#
# Create Database
#
# create a database in the account uri that is provided
#
function CreateDatabase([string]$rootUri, [string]$key, [string]$dbname) {
    $uri = $rootUri + "/dbs"
    $date = GetUTDate
    $hdr = BuildHeaders -action 'post' -resType dbs -date $date -key $key
    $body = @{"id"=$dbname} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $hdr -Body $body
    Write-Host ("Database Created: " + $dbname)
}

#
# Delete Database
#
# delete a database..... be careful!
#
function DeleteDatabase([string]$rootUri, [string]$key, [string]$dbname) {
    $uri = $rootUri + "/dbs/" + $dbname
    $date = GetUTDate
    $hdr = BuildHeaders -action 'delete' -resType $("dbs/" + $dbname) -date $date -key $key
    $response = Invoke-RestMethod -Uri $uri -Method Delete -Headers $hdr
    Write-Host ("Database Deleted: " + $dbname)
}

#
# Get Collections
#
# return all collections within a certain database
#
function GetCollections([string]$rootUri, [string]$key, [string]$dbname){
    $uri = $rootUri + "/dbs/" + $dbname + "/colls"
    $date = GetUTDate
    $hdr = BuildHeaders -action 'get' -resType colls -resourceId $("dbs/" + $dbname) -date $date -key $key
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $hdr
    $response.DocumentCollections
    Write-Host ("Found " + $response.DocumentCollections.Count + " DocumentCollection(s)")
}

#
# Create Collection
#
# Create a collection in the database provided
#
# $collName
#     The name of the collection that needs to be created. Exp: mycollection
#
# $throughput
#     The throughput is 400 to 10000
#
function CreateCollection([string]$rootUri, [string]$key, [string]$dbname, [string]$collName, [int]$throughput=400) {
    $uri = $rootUri + "/dbs/" + $dbname + "/colls"
    $date = GetUTDate
    $hdr = BuildHeaders -action 'post' -resType colls -resourceId $("dbs/" + $dbname) -date $date -key $key
    $hdr.Add("x-ms-offer-throughput", $throughput)
    $body = @{"id"=$collName} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $hdr -Body $body
    Write-Host ("Collection Created: " + $collName)
}

#
# Delete Collection
#
# Delete a collection in the database provided
#
# $colName
#     The name of the collection to be deleted.
#
# $dbname
#     The name of the database to delete
#
function DeleteCollection([string]$rootUri, [string]$key, [string]$dbname, [string]$collname) {
    $uri = $rootUri + "/dbs/" + $dbname + "/colls/" + $collname
    $date = GetUTDate
    $hdr = BuildHeaders -action 'delete' -resType colls -resourceId $("dbs/" + $dbname + "/colls/" + $collname) -date $date -key $key
    $response = Invoke-RestMethod -Uri $uri -Method Delete -Headers $hdr
    Write-Host ("Collection Deleted: " + $collname)
}
