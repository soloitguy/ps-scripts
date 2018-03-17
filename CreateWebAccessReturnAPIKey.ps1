<#
    Prepare to Set Annotations Create API Access to Application Insights and 
    return API Key to release pipeline to us in Annotation Task


    $ResourceGroupName
        The resource group name to retrieve last deployment from
    
    $ClientSecret
        Client secret to get Autorization Header

    $ClientId
        SPN - Application Id

    $APIVersion
        The Version of the API to use to execute these commands

    The  following statement is used for executing locally 
        $pass = ConvertTo-SecureString "<PasswordOfSPN>" -AsPlainText –Force
        $cred = New-Object -TypeName pscredential –ArgumentList "<ApplicationID@azureDomain>", $pass 
        Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId "<Tenant ID>"
         
         https://visualstudio.uservoice.com/forums/357324-application-insights/suggestions/13607550-enable-creation-and-management-of-api-keys-via-pow#{toggle_previous_statuses}
         https://dev.int.applicationinsights.io/documentation/Authorization/API-key-and-App-ID
#>


Param(
	[Parameter(Mandatory=$true)]
    [string] $ResourceGroup,

    [Parameter(Mandatory=$true)]
    [string] $ClientSecret,

    [Parameter(Mandatory=$true)]
    [string] $ClientId,
    
    [Parameter(Mandatory=$false)]
    [string] $APIVersion = "2015-05-01"
    )

$groupResources = Get-AzureRMResource | Where {$_.ResourceGroupName -eq $ResourceGroup}
$appInsightResource = $groupResources | Where {$_.ResourceType -eq "Microsoft.Insights/components"} 

$TenantId = (Get-AzureRmSubscription -SubscriptionId $appInsightResource.SubscriptionId).TenantId

#input variables for the API access
$base = $appInsightResource.ResourceId + "/apikeys"
$linkedWriteProperties = $appInsightResource.ResourceId+"/annotations"
$WebAccessName = $appInsightResource.Name + "-Annotation"


function GetAuthToken
 {
     try
    {
        $result = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantId/oauth2/token?api-version=1.0 -Method Post `
                    -Body @{"grant_type" = "client_credentials"; "resource" = "https://management.core.windows.net/"; "client_id" = $ClientId; "client_secret" = $ClientSecret }
        
        return $result.access_token
    }
    catch
    {
        Write-Host "Unable to retrieve Authorize Token"
    }
 } 


function Execute-ARMQuery ($HTTPVerb, $SubscriptionId, $Base, $Query, $Data, $APIVersion, [switch] $Silent) 
{
    $return = $null
    $token = GetAuthToken
    $header = "Bearer " + $token 

    $headers = @{"Authorization"=$header;"Accept"="application/json"}
    $uri = [string]::Format("{0}{1}?api-version={2}{3}","https://management.azure.com", $Base, $APIVersion, $Query)

    if($Data -ne $null)
    {
        $enc = New-Object "System.Text.ASCIIEncoding"
        $body = ConvertTo-Json -InputObject $Data
        $byteArray = $enc.GetBytes($body)
        $contentLength = $byteArray.Length
        $headers.Add("Content-Type","application/json")
        $headers.Add("Content-Length",$contentLength)
    }
    if(-not $Silent)
    {
        Write-Host HTTP $HTTPVerb $uri -ForegroundColor Cyan
        Write-Host
    }
    
        if($Data -ne $null)
        {
            if(-not $Silent)
                {
                    Write-Host
                    Write-Host $body -ForegroundColor Cyan
                }
        }

        $result = Invoke-WebRequest -Method $HTTPVerb -Uri $uri -Headers $headers -Body $body -UseBasicParsing

        if($result.StatusCode -ge 200 -and $result.StatusCode -le 399)
        {
            if(-not $Silent)
            {
                Write-Host "Query successfully executed." -ForegroundColor Cyan
            }
            if($result.Content -ne $null)
            {
                $json = (ConvertFrom-Json $result.Content)
                if($json -ne $null)
                {
                    $return = $json
                    if($json.value -ne $null)
                    {
                        $return = $json.value
                    }
                }
            }
        }
    return $return
}


#Get existing Api Access Key and delete it if it exists
try
{
    $returnVal = Execute-ARMQuery -SubscriptionId $appInsightResource.SubscriptionId -HTTPVerb "GET" -Base $base -APIVersion $APIVersion 
    $existingApiAccess =  $returnVal | where {$_.name -eq $WebAccessName} | Select Id
}

catch
{
    Write-Host "Unable to Get Current Api Key"
    Write-Host "$($_.Exception.GetType().Fullname)"
    Write-Host "$($_.Exception.Message)"
}
IF ($existingApiAccess.id)
    {
        try
        {
            $returnVal = Execute-ARMQuery -SubscriptionId $appInsightResource.SubscriptionId -HTTPVerb "DELETE" -Base $existingApiAccess.id -APIVersion $APIVersion -Query "&query=DeleteApiKeyQuery&part=DeleteApiKeyCommand"
        }
        catch
        {
            Write-Host "Unable to Delete Current Api Key"
        }
    }


#Create the API Access Key and return the API Key
try
    {
        $apiAccess = Execute-ARMQuery -APIVersion $APIVersion -Base $base -Data @{name=$WebAccessName; linkedWriteProperties=@($linkedWriteProperties)} -HTTPVerb "POST" -SubscriptionId $appInsightResource.SubscriptionId
        $apiKey = $apiAccess.apiKey

        $insightsComponent = Get-AzureRmResource -ResourceGroupName $ResourceGroup -ResourceType "microsoft.insights/components" -isCollection -ExpandProperties -ApiVersion $APIVersion 
        $insightsAppId = $insightsComponent.Properties.AppId
    
        Write-Host ("##vso[task.setvariable variable=apiKey;]$apiKey")
        Write-Host ("##vso[task.setvariable variable=insightsAppId;]$insightsAppId")
    }
catch
    {
        Write-Host "Unable to Set Current Api Key and Return Variables"
        Write-Host "$($_.Exception.GetType().Fullname)"
        Write-Host "$($_.Exception.Message)"
    }


