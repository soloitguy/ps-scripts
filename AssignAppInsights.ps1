PARAM ([Parameter(Mandatory=$true)][string] $ResourceGroupName)

$groupName = $ResourceGroupName
$groupResources = Get-AzureRMResource | Where {$_.ResourceGroupName -eq $groupName}
$webApps = $groupResources | Where {$_.ResourceType -eq "Microsoft.Web/sites"} | Select ResourceId
$appResourceId = $webApps[0].ResourceId
$appInsightResource = $groupResources | Where {$_.ResourceType -eq "Microsoft.Insights/components"} 

$hashKey = "hidden-link:$appResourceId"
$hashValue = "Resource"

$hashKey

$appInsightTag = $appInsightResource.Tags

IF ($appInsightTag.count -eq 0) {
    try {
        $appInsightTag.Add("$hashKey", "$hashValue")
        Set-azureRmResource -ResourceID $appInsightResource.ResourceId -Tag $appInsightTag -Force
        }
    catch {
        Write-Host "Could not add the tag"
        }
    }
ELSE {
     Write-Host "Tags already exist."
     }







