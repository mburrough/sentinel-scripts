#Change these values
$tenantId = "Your-subscription-AAD-tenant-ID"
$subscriptionID = "Your-Azure-subscription-ID"

$logicAppName = "Your-logic-app-name"
$logicAppRG = "Your-logic-app-resource-group-name"
$triggerName = "When_a_response_to_an_Azure_Sentinel_alert_is_triggered" # This is the default

$workspaceName = "Your-Workspace-Name" 
$sentinelRG = "Your-Sentinel-Resouce-Group-name"

#--------------------

Import-Module Az
Import-Module Az.SecurityInsights
Connect-AzAccount -TenantId $tenantId
Select-AzSubscription -SubscriptionId $subscriptionID -TenantId  $tenantId

$logicapp = Get-AzLogicApp -ResourceGroupName $logicAppRG -Name $logicAppName
$trigger = Get-AzLogicAppTrigger -ResourceGroupName $logicAppRG -Name $logicAppName -TriggerName $triggerName
$triggerUri = Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $logicAppRG -Name $logicAppName -TriggerName $triggerName

$rules = Get-AzSentinelAlertRule -ResourceGroupName $sentinelRG -WorkspaceName $workspaceName
foreach($rule in $rules)
{
    if($rule.Kind -eq "Error")
    {
        write-host "Skipping rule $($rule.Name), because Kind==Error"
    }
    else
    {
        write-host "Adding action to $($rule.Name)"
        New-AzSentinelAlertRuleAction -ResourceGroupName $sentinelRG -WorkspaceName $workspaceName -AlertRuleId $($rule.Name) -LogicAppResourceId $($logicapp.Id) -TriggerUri $($triggerUri.Value)
    }
}
