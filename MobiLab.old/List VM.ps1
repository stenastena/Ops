Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b
$rgName = 'rgVmMigrated' # Resource Group Name
Get-AzVM -ResourceGroupName $rgName | Format-Table -AutoSize
