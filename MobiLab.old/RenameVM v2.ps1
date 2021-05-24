#Connect-AzAccount
Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b

$rgName = 'rgVmMigrated' # Resource Group Name
$vmOldName = 'vmApp0' # OLd Virtual Machine Name
$newVMName = 'vmApp5' # Set the name of the new virtual machine

# Export VM properties
#$oldVMorig=Get-AzVM -ResourceGroupName $rgName -Name $vmOldName | Export-Clixml C:\TMP\VM_Backup.xml -Depth 5
$oldVM = Get-AzVM -ResourceGroupName $rgName -Name $vmOldName 
#Write-Output $oldVM | Export-Clixml C:\TMP\VM_Backup.xml -Depth 5

# Import VM settings from backup XML and store it in a variable
#$oldVM = Import-Clixml C:\TMP\VM_Backup.xml

<#
Write-Output "из XML что в переменной oldVM"
$oldVM

Write-Output "смотрим, что в  объекте сохраненном напрямую в переменную oldVMorig"
$oldVMorig
#>


# Delete the Old VM
Remove-AzVM -ResourceGroupName $oldVM.ResourceGroupName -Name $oldVM.Name -Force

# Initiate a new virtual machine configuration
$newVM = New-AzVMConfig -VMName $newVMName -VMSize $oldVM.HardwareProfile.VmSize -Tags $oldVM.Tags
#$newVM = New-AzVMConfig -VMName $newVMName -VMSize $oldVMorig.HardwareProfile.VmSize -Tags $oldVMorig.Tags

# Attach the OS Disk of the old VM to the new VM
Set-AzVMOSDisk -VM $newVM -CreateOption Attach -ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id -Name $oldVM.StorageProfile.OsDisk.Name -Windows

# Attach all NICs of the old VM to the new VM
$oldVM.NetworkProfile.NetworkInterfaces | % {Add-AzVMNetworkInterface -VM $newVM -Id $_.Id}

# Attach all Data Disks (if any) of the old VM to the new VM
$oldVM.StorageProfile.DataDisks | % {Add-AzVMDataDisk -VM $newVM -Name $_.Name -ManagedDiskId $_.ManagedDisk.Id -Caching $_.Caching -Lun $_.Lun -DiskSizeInGB $_.DiskSizeGB -CreateOption Attach}

# Create the new virtual machine
New-AzVM -ResourceGroupName $rgName -Location $oldVM.Location -VM $newVM

#Optional. Confirm the existence of the new VM by running the Get-AzVM command below.
Get-AzVM -ResourceGroupName $rgName -VMName $newVMName

