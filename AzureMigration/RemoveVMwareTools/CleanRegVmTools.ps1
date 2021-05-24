# If script doesn't work due the Execution policy restrictions, perform these two commands from the Powshershell console
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
#Unblock-File -Path .\CleanRegVmTools.ps1

function Search-Registry { 
<# 
This function can search registry key names, value names, and value data (in a limited fashion). It outputs custom objects that contain the key and the first match type (KeyName, ValueName, or ValueData). 
Search-Registry -Path HKLM:\SYSTEM\CurrentControlSet\Services\* -SearchRegex "svchost" -ValueData 
Search-Registry -Path HKLM:\SOFTWARE\Microsoft -Recurse -ValueNameRegex "ValueName1|ValueName2" -ValueDataRegex "ValueData" -KeyNameRegex "KeyNameToFind1|KeyNameToFind2" 
#> 
    [CmdletBinding()] 
    param( 
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)] 
        [Alias("PsPath")] 
        # Registry path to search 
        [string[]] $Path, 
        # Specifies whether or not all subkeys should also be searched 
        [switch] $Recurse, 
        [Parameter(ParameterSetName="SingleSearchString", Mandatory)] 
        # A regular expression that will be checked against key names, value names, and value data (depending on the specified switches) 
        [string] $SearchRegex, 
        [Parameter(ParameterSetName="SingleSearchString")] 
        # When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested) 
        [switch] $KeyName, 
        [Parameter(ParameterSetName="SingleSearchString")] 
        # When the -SearchRegex parameter is used, this switch means that the value names will be tested (if none of the three switches are used, value names will be tested) 
        [switch] $ValueName, 
        [Parameter(ParameterSetName="SingleSearchString")] 
        # When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested) 
        [switch] $ValueData, 
        [Parameter(ParameterSetName="MultipleSearchStrings")] 
        # Specifies a regex that will be checked against key names only 
        [string] $KeyNameRegex, 
        [Parameter(ParameterSetName="MultipleSearchStrings")] 
        # Specifies a regex that will be checked against value names only 
        [string] $ValueNameRegex, 
        [Parameter(ParameterSetName="MultipleSearchStrings")] 
        # Specifies a regex that will be checked against value data only 
        [string] $ValueDataRegex 
    ) 

    begin { 
        switch ($PSCmdlet.ParameterSetName) { 
            SingleSearchString { 
                $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData")) 
                if ($KeyName -or $NoSwitchesSpecified) { $KeyNameRegex = $SearchRegex } 
                if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex } 
                if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex } 
            } 
            MultipleSearchStrings { 
                # No extra work needed 
            } 
        } 
    } 

    process { 
        foreach ($CurrentPath in $Path) 
        { 
            Get-ChildItem $CurrentPath -Recurse:$Recurse |  
                ForEach-Object { 
                    $Key = $_ 

                    if ($KeyNameRegex) 
                    {  
                        if ($Key.PSChildName -match $KeyNameRegex) 
                        {  
                            #Write-host $Key
                            Return $Key
                        }  
                    } 

                    if ($ValueNameRegex) 
                    {  
                        if ($Key.GetValueNames() -match $ValueNameRegex) 
                        {  
                            #Write-host $Key
                            Return $Key
                        }  
                    } 

                    if ($ValueDataRegex) 
                    {  
                        if (($Key.GetValueNames() | % { $Key.GetValue($_) }) -match $ValueDataRegex) 
                        {  
                            #Write-host $Key
                            Return $Key
                        } 
                    } 
                } 
        } 
    } 
} 


Write-Host "1. Seach property in HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" -ForegroundColor Green
$FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"  -ValueDataRegex "VMWare tools"
Write-Host "Found:"
Write-Output $FullKeyPath | Get-Item
foreach ($EachKey in $FullKeyPath) {
    Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
    Write-Output $EachKey | Remove-Item
}

Write-Host "2. Seach property in HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products" -ForegroundColor Green
$FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products" -ValueDataRegex "VMWare tools"
Write-Host "Found:"
Write-Output $FullKeyPath | Get-Item
foreach ($EachKey in $FullKeyPath) {
    Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
    Write-Output $EachKey | Remove-Item
}


Write-Host "3. Seach key in HKEY_LOCAL_MACHINE\Software\VMware" -ForegroundColor Green
$FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\VMware"  -KeyNameRegex "VMWare tools"
Write-Host "Found:"
Write-Output $FullKeyPath | Get-Item
foreach ($EachKey in $FullKeyPath) {
    Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
    Write-Output $EachKey | Remove-Item
}

<#
# That is excessive requirement to remove the keys on this path, because that is mirror of previouse keys
Write-Host "4. Seach property in HKEY_CLASSES_ROOT\Installer\Products" -ForegroundColor Green
$FullKeyPath = Search-Registry -Path "Registry::HKEY_CLASSES_ROOT\Installer\Products"   -ValueDataRegex "VMWare tools"
Write-Host "Found:"
Write-Output $FullKeyPath | Get-Item
#Write-Host "Delete..." -ForegroundColor Yellow
#Write-Output $FullKeyPath | Remove-Item
#>

