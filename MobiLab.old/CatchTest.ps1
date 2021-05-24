<#
$VMList = ConvertFrom-Csv @'
OldName,    NewName,    OS
VmNewWin22,  VmNewWin222, Windows
VmNewLin00,     VmNewLin000,  Linux
'@
#>
Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b
$rgName = 'rgVmMigrated' # Resource Group Name

$VMList = ConvertFrom-Csv @'
OldName,    NewName,    OS
VmNewWin227,  VmNewWin222, Windows
VmNewWin222,  VmNewWin2222, Windows
'@




    foreach ($VM in $VMList) 
    {
    
        try {
            $VM.OldName
            Get-AzVM -ResourceGroupName $rgName -Name $VM.OldName -ErrorAction Stop

    }
    catch [System.UnauthorizedAccessException]
    {
    Write-Host ″File is not accessible.″
    }
    catch {
    Write-Host ″Other type of error was found:″
    Write-Host ″Exception type is $($_.Exception.GetType().Name)″
    }
    finally {
    Write-Host ″Finish.″
    }

    }  
