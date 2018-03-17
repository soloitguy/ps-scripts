#
# PS Script Description: Add Topics and Subscriptions to Existing Party ServiceBus, if they do not exist.
#
# This script will loop through all Connfigured Subscriptions in /Configuration/ServiceBusConfig.json
#
# $serviceBusResourceGroup
#     The resource group name where the ServiceBus exists, that we need to modify.
#
# $serviceBusNameSpace
#     The namespace of the service bus that we are going to add topics and subscriptions to
#

PARAM(
[Parameter(Mandatory=$true)][string]$serviceBusResourceGroup,
[Parameter(Mandatory=$true)][string]$serviceBusNameSpaces,
[Parameter(Mandatory=$false)][string]$paramFile
)

if($paramFile -eq $null)
{
    #exiting as the calling release calls this script, but does not require it, so it will pass a null param file, and we won't run.
    exit
}

$busArray = $serviceBusNameSpaces.split(',')

foreach($bus in $busArray)
{
    $configObject = (Get-Content $paramFile) -join "`n" | ConvertFrom-Json

    if(!$configObject) {
        throw "Service Bus Configuration File cannot be loaded"
    }

    foreach($queue in $configObject.Queues)
    {
        Get-AzureRmServiceBusQueue -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -QueueName $queue.name -ev queueNotPresent -ea 0
        Write-Host "Check if $queue.name exists"
        if(-not $queueNotPresent)
        {
            Write-Host "Removing $queue.name"
            Remove-AzureRmServiceBusQueue -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -QueueName $queue.name
            Write-Host "Removed $queue.name"
            $queueNotPresent = $true
        }

        if($queueNotPresent -and $queue.name -like "*.Response")
        {
            New-AzureRmServiceBusQueue -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -QueueName $queue.name -EnablePartitioning $true -RequiresSession $true
            Write-Host "$queue.name created with Sessions enabled"
        }
        elseif($queueNotPresent -and $queue.name -notlike "*.Response")
        {
            New-AzureRmServiceBusQueue -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -QueueName $queue.name -EnablePartitioning $true
            Write-Host "$queue.name created with Sessions disabled"
        }
    }
    
    foreach($topic in $configObject.Topics)
    {
        Get-AzureRmServiceBusTopic -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -TopicName $topic.name -ev topicNotPresent -ea 0

        if ($topicNotPresent)
        {
            New-AzureRmServiceBusTopic -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -TopicName $topic.name -EnablePartitioning $true
        }
    }

    foreach($subscription in $configObject.Subscriptions)
    {
        Get-AzureRmServiceBusSubscription -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -TopicName $subscription.topic -SubscriptionName $subscription.name -ev subscriptionNotPresent -ea 0

        if($subscriptionNotPresent)
        {
            Get-AzureRmServiceBusTopic -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -TopicName $topic.name -ev topicNotPresent -ea 0
            if($topicNotPresent){
                Sleep 10
                New-AzureRmServiceBusSubscription -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -TopicName $subscription.topic -SubscriptionName $subscription.name
            }
            else {
                New-AzureRmServiceBusSubscription -ResourceGroup $serviceBusResourceGroup -NamespaceName $bus -TopicName $subscription.topic -SubscriptionName $subscription.name
            }
        }
    }

    

}
