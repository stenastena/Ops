#Connect-AzAccount -TenantId "ec73c9e5-b6b6-45a6-962d-822e86cdc0fa"
#Select-AzSubscription -SubscriptionID "586c2e9a-f8e3-49cc-8765-4e430f697415"



$rgName = 'Automation' # Resource Group Name

# List replicating VMs and filter the result for selecting a replicating VM. This cmdlet will not return all properties of the replicating VM.
$MigProject = "AutomationProject"

# Get details of the Azure Migrate project
#$MigrateProject = Get-AzMigrateProject -Name $MigProject -ResourceGroupName $rgName

#$ReplicatingServers = 
Get-AzMigrateServerReplication -ProjectName $MigProject -ResourceGroupName $rgName # -MachineName MyTestVM
#Write-Host "Replicated servers are: $ReplicatingServers"