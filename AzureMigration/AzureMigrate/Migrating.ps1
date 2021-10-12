#Connect-AzAccount -TenantId "ec73c9e5-b6b6-45a6-962d-822e86cdc0fa"
#Select-AzSubscription -SubscriptionID "586c2e9a-f8e3-49cc-8765-4e430f697415"

$rgName = 'Automation' # Resource Group Name
$TargetRgName = 'AutomationTarget' # Target resource Group Name
$OnPremisVMname = "Win2k12"
$TargetNicName0 = "tst-Win2k12-1-eu-nic0"
$TargetNicName1 = "tst-Win2k12-1-eu-nic1"
$TargetVMName = "tst-Win2k12-1-eu-vm"
$MigProject = "AutomationProject"
$TargetOSDiskName = "qa2-Win2k12-1-eu-osdisk"
$TargetDataDiskName0 = "qa2-Win2k12-1-eu-datadisk0"
$TargetDataDiskName1 = "qa2-Win2k12-1-eu-datadisk1"
$TargetDataDiskName2 = "qa2-Win2k12-1-eu-datadisk2"
$Diskmapping = @() #Array of disk objects with new names and so on
$NicMapping = @() #Array of NIC objects with new names and so on

# Get details of the Azure Migrate project
#$MigrateProject = Get-AzMigrateProject -Name $MigProject -ResourceGroupName $rgName

# List replicating VMs and filter the result for selecting a replicating VM. 
# This cmdlet will not return all properties of the replicating VM.
$ReplicatingServer = Get-AzMigrateServerReplication -ProjectName $MigProject `
-ResourceGroupName $rgName -MachineName $OnPremisVMname

# Retrieve all properties of a replicating VM
$ReplicatingServer = Get-AzMigrateServerReplication -TargetObjectID $ReplicatingServer.Id

# View properties of the replicating object
#Write-Output "View properties of the replicating object:"
#Write-Output $ReplicatingServer.ProviderSpecificDetail | Get-Member

# View all details of the replicating server
#Write-Output "Parameters of replicated but not migrated server:"
#Write-Output $ReplicatingServer.ProviderSpecificDetail | Format-List

# View NIC details of the replicating server
#Write-Output "NIC Parameter of replicated but not migrated server:"
#Write-Output $ReplicatingServer.ProviderSpecificDetail.VMNic | Format-List

<#
Write-Output "NICs:"
foreach ($nic in $ReplicatingServer.ProviderSpecificDetail.VMNic) 
{
    Write-Output ""
    Write-Output $nic.NicId
    Write-Output $nic.SourceIPAddress
    Write-Output $nic.IsPrimaryNic
    Write-Output $nic.TargetNicName
}
#>

# View Disk details of the replicating server
#Write-Output "Disk Parameter of replicated but not migrated server:"
#Write-Output $ReplicatingServer.ProviderSpecificDetail.ProtectedDisk | Get-Member
#Write-Output $ReplicatingServer.ProviderSpecificDetail.ProtectedDisk | Format-List



# Change target disk names
$n=0
foreach ($DiskId in $ReplicatingServer.ProviderSpecificDetail.ProtectedDisk.DiskID) {
 
    $Disk = Set-AzMigrateDiskMapping -DiskID $DiskId -DiskName "disk-$n" 
    # Add to array next disk parameters
    $DiskMapping += $Disk
    $n = $n + 1 #only for automatic target disk name
        
} 
Write-Output " "
Write-Output "Disk Parameters:"
$DiskMapping

$n=0
# Specify the NIC properties to be updated for a replicating VM.
foreach ($NicId in $ReplicatingServer.ProviderSpecificDetail.VMNic.NicId) {
    
    $Nic = New-AzMigrateNicMapping -NicId $NicId -TargetNicName "nic-$n" `
    # -TargetNicIP ###.###.###.### -TargetNicSelectionType Primary
    $NicMapping += $Nic
    $n = $n + 1 #only for automatic target NIC name
}
Write-Output " "
Write-Output "NIC Parameters:"
Write-Output $NicMapping 

# Update the NIC and disks configuration 
$UpdateJob = Set-AzMigrateServerReplication -InputObject $ReplicatingServer -TargetVMSize Standard_B1s `
-TargetVMName $TargetVMName -NicToUpdate $NicMapping -DiskToUpdate $DiskMapping

Write-Output "Parameters of migrating job:"
Write-Output $UpdateJob | Format-list


<#
Comments, Tasks and so on
#>