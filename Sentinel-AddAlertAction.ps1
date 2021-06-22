# READ LICENSE TERMS AT BOTTOM OF FILE BEFORE USE!
 
# Change these values:
$tenantId = "Your-subscription-AAD-tenant-ID"
$subscriptionID = "Your-Azure-subscription-ID"

$logicAppName = "Your-logic-app-name"
$logicAppRG = "Your-logic-app-resource-group-name"
$triggerName = "When_a_response_to_an_Azure_Sentinel_alert_is_triggered" # This is the default

$workspaceName = "Your-Workspace-Name" 
$sentinelRG = "Your-Sentinel-Resouce-Group-name"

#---- No need to edit below this line ----

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

# -----------------------------------

# Copyright 2021 Matt Burrough
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
