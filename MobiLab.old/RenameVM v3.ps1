#Connect-AzAccount
Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b
$rgName = 'rgVmMigrated' # Resource Group Name
#$vmOldName = 'vmWin0' # OLd Virtual Machine Name
#$vmNewName = 'vmNewWin0' # Set the name of the new virtual machine
#$TypeOfOS = 'Windows'
#$TypeOfOS = Linux

function Set-VmNewName ($rgName, $vmOldName,$newVMName, $KindOfOS) 
{
    # $KindOfOS have to be Windows or Linux

    # Saving VM properties
    #$oldVM = Get-AzVM -ResourceGroupName $rgName -Name $vmOldName 

    # Export VM properties
    #Get-AzVM -ResourceGroupName $rgName -Name $vmOldName | Export-Clixml C:\TMP\VM_Backup.xml -Depth 5
    try 
    {
        $oldVM = Get-AzVM -ResourceGroupName $rgName -Name $vmOldName -ErrorAction Stop    
    }
    catch 
    {
#       Write-Host "Something wrong. Probably the source VM '$vmOldName' doesn't exist." -ForegroundColor Yellow
#       Write-Host "Continue to work..." -ForegroundColor Green 
    }

#Write-Output $oldVM | Export-Clixml C:\TMP\VM_Backup.xml -Depth 5

# Import VM settings from backup XML and store it in a variable
#$oldVM = Import-Clixml C:\TMP\VM_Backup.xml

    # Delete the Old VM
    Remove-AzVM -ResourceGroupName $oldVM.ResourceGroupName -Name $oldVM.Name -Force

    # Initiate a new virtual machine configuration
    $newVM = New-AzVMConfig -VMName $newVMName -VMSize $oldVM.HardwareProfile.VmSize -Tags $oldVM.Tags

    # Attach the OS Disk of the old VM to the new VM
    if ($KindOfOS -eq 'Windows') {
        Set-AzVMOSDisk -VM $newVM -CreateOption Attach -ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id -Name $oldVM.StorageProfile.OsDisk.Name -Windows
    }
    else {
        Set-AzVMOSDisk -VM $newVM -CreateOption Attach -ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id -Name $oldVM.StorageProfile.OsDisk.Name -Linux
    }
    
    # Attach all NICs of the old VM to the new VM
    $oldVM.NetworkProfile.NetworkInterfaces | ForEach-Object {Add-AzVMNetworkInterface -VM $newVM -Id $_.Id}

    # Attach all Data Disks (if any) of the old VM to the new VM
    $oldVM.StorageProfile.DataDisks | ForEach-Object {Add-AzVMDataDisk -VM $newVM -Name $_.Name -ManagedDiskId $_.ManagedDisk.Id -Caching $_.Caching -Lun $_.Lun -DiskSizeInGB $_.DiskSizeGB -CreateOption Attach}

    # Create the new virtual machine
    New-AzVM -ResourceGroupName $rgName -Location $oldVM.Location -VM $newVM

    #Check the existence and parameters of the new VM
    Get-AzVM -ResourceGroupName $rgName -VMName $newVMName
}




$VMList = ConvertFrom-Csv @'
OldName,        NewName,        OS
VmNewWin22,     VmNewWin2222,   Windows
VmNewLin000,    VmLin0,        Linux
VmNewLin11,     VmLin1,        Linux
VmNewWin2,      VmWin2,        Windows
'@

foreach ($VM in $VMList) 
{
    try 
    {    
        Set-VmNewName -rgName $rgName -vmOldName $VM.OldName -newVMName $VM.NewName -KindOfOS $VM.OS -ErrorAction Stop
    }
    catch
    {
        Write-Host "Something wrong. Probably the source VM '$($VM.OldName)' doesn't exist." -ForegroundColor Yellow
        Write-Host "Continue to work..." -ForegroundColor Green    
    }
}

Write-Output "There are next VMs:"
Get-AzVM -ResourceGroupName $rgName | Format-Table -AutoSize