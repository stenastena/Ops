#Connect-AzAccount
Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b
$rgName = 'rgVmMigrated' # Resource Group Name

#Import VMs for renaming
$VMList = Import-Csv -Path .\VMs.csv

#There is no way to directly rename a VM in Azure. 
#We have to split the current VM into its components.
#After that, we create a new VM and connect the old parts to it.
function Set-VmNewName ($rgName, $vmOldName,$newVMName, $KindOfOS) 
{
    # $KindOfOS have to be Windows or Linux
    try 
    {
    # Save VM properties
    
    $oldVM = Get-AzVM -ResourceGroupName $rgName -Name $vmOldName -ErrorAction Stop    
    
    # Delete the Old VM
    Remove-AzVM -ResourceGroupName $oldVM.ResourceGroupName -Name $oldVM.Name -Force -ErrorAction Stop

    # Initiate a new virtual machine configuration
    $newVM = New-AzVMConfig -VMName $newVMName -VMSize $oldVM.HardwareProfile.VmSize -Tags $oldVM.Tags -ErrorAction Stop

    # Attach the OS Disk of the old VM to the new VM
    if ($KindOfOS -eq 'Windows') {
        Set-AzVMOSDisk -VM $newVM -CreateOption Attach -ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id -Name $oldVM.StorageProfile.OsDisk.Name -Windows -ErrorAction Stop
    }
    else {
        Set-AzVMOSDisk -VM $newVM -CreateOption Attach -ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id -Name $oldVM.StorageProfile.OsDisk.Name -Linux -ErrorAction Stop
    }
    
    # Attach all NICs of the old VM to the new VM
    $oldVM.NetworkProfile.NetworkInterfaces | ForEach-Object {Add-AzVMNetworkInterface -VM $newVM -Id $_.Id} -ErrorAction Stop

    # Attach all Data Disks (if any) of the old VM to the new VM
    $oldVM.StorageProfile.DataDisks | ForEach-Object {Add-AzVMDataDisk -VM $newVM -Name $_.Name -ManagedDiskId $_.ManagedDisk.Id -Caching $_.Caching -Lun $_.Lun -DiskSizeInGB $_.DiskSizeGB -CreateOption Attach} -ErrorAction Stop

    # Create the new virtual machine
    New-AzVM -ResourceGroupName $rgName -Location $oldVM.Location -VM $newVM -ErrorAction Stop
    }
    
    catch 
    {
        Write-Host "Something wrong." -ForegroundColor Blue
        Write-Host "Probably the source VM '$vmOldName' doesn't exist or connection between your PC and Azure was lost." -ForegroundColor Blue
        Write-Host "The process of renaming continues to work..." -ForegroundColor Blue
    }
    
    #Check the existence and parameters of the new VM
    #Get-AzVM -ResourceGroupName $rgName -VMName $newVMName
}

foreach ($VM in $VMList) 
{
    try 
    {    
        Set-VmNewName -rgName $rgName -vmOldName $VM.OldName -newVMName $VM.NewName -KindOfOS $VM.OS -ErrorAction Stop
    }
    catch
    {
        #Write-Host "Something wrong. Probably the source VM '$($VM.OldName)' doesn't exist or connection between your PC and Azure was lost." -ForegroundColor Yellow
        #Write-Host "The process of renaming continues to work..." -ForegroundColor Green    
    }
}

Write-Output "There are next VMs:"
Get-AzVM -ResourceGroupName $rgName | Format-Table -AutoSize