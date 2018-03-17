PARAM(
[Parameter(Mandatory=$true)] [string] $ResourceGroupName,
[Parameter(Mandatory=$true)] [Hashtable] $Tags
)

$ResourceGroup = (Get-AzureRmResourceGroup -Name $ResourceGroupName)

if(!$ResourceGroup) {
    throw "Resource Group $ResourceGroupName does not exit, cannot update."
}

$CurrentTags = $ResourceGroup.Tags

foreach($Tag in $Tags.Keys) {
    $Value = $Tags.Item($Tag)

    if($CurrentTags) {
        if($CurrentTags.ContainsKey($Tag)) {
            $CurrentTags.Set_Item($Tag, $Value)
        } else {
            $CurrentTags.Add($Tag, $Value)
        }

        $NewTags = $CurrentTags
    } else {
        Write-Output "Tags do not exist on resource"
        $NewTags = $Tags
    }
}

Set-AzureRmResourceGroup -Name $ResourceGroupName -Tag $NewTags