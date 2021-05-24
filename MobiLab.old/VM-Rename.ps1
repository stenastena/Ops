#Set-Location C:\Users\osherovsy\GoogleDrive\MyProjects\MobiLab
#Connect-AzAccount
#Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b

$VMS = Get-AzVM -ResourceGroupName rgVmMigrated

#$VMS | Format-Table

#$VMS.Item(3).Name

foreach($vm in $VMS)
{
    $vm.Name
}

#$vms[2].Name

