function Search-Registry { 
<# 
.SYNOPSIS 
Searches registry key names, value names, and value data (limited). 

.DESCRIPTION 
This function can search registry key names, value names, and value data (in a limited fashion). It outputs custom objects that contain the key and the first match type (KeyName, ValueName, or ValueData). 

.EXAMPLE 
Search-Registry -Path HKLM:\SYSTEM\CurrentControlSet\Services\* -SearchRegex "svchost" -ValueData 

.EXAMPLE 
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
        foreach ($CurrentPath in $Path) { 
            Get-ChildItem $CurrentPath -Recurse:$Recurse |  
                ForEach-Object { 
                    $Key = $_ 

                    if ($KeyNameRegex) {  
                        Write-Verbose ("{0}: Checking KeyNamesRegex" -f $Key.Name)  

                        if ($Key.PSChildName -match $KeyNameRegex) {  
                            Write-Verbose "  -> Match found!" 
                            return [PSCustomObject] @{ 
                                Key = $Key 
                                #Reason = "KeyName" 
                            } 
                        }  
                    } 

                    if ($ValueNameRegex) {  
                        Write-Verbose ("{0}: Checking ValueNamesRegex" -f $Key.Name) 

                        if ($Key.GetValueNames() -match $ValueNameRegex) {  
                            Write-Verbose "  -> Match found!" 
                            return [PSCustomObject] @{ 
                                Key = $Key 
                                #Reason = "ValueName" 
                            } 
                        }  
                    } 

                    if ($ValueDataRegex) {  
                        Write-Verbose ("{0}: Checking ValueDataRegex" -f $Key.Name) 

                        if (($Key.GetValueNames() | % { $Key.GetValue($_) }) -match $ValueDataRegex) {  
                            Write-Verbose "  -> Match!" 
                            $output144 = @( 
                                $Key 
                                #Reason = "ValueData" 
                                )
                             return $output144
                        } 
                    } 
                } 
        } 
    } 
} 


Write-Host "1. Seach property in HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" -ForegroundColor Green
$result1 = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"  -ValueDataRegex "VMWare tools"

Write-Host "2. Seach property in HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products" -ForegroundColor Green
$result2 = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products" -ValueDataRegex "VMWare tools"

Write-Host "3. Seach property in HKEY_CLASSES_ROOT\Installer\Products" -ForegroundColor Green
$result3 = Search-Registry -Path "Registry::HKEY_CLASSES_ROOT\Installer\Products"   -ValueDataRegex "VMWare tools"

Write-Host "4. Seach key in HKEY_LOCAL_MACHINE\Software\VMware" -ForegroundColor Green
$result4 = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\VMware"  -KeyNameRegex "VMWare tools"

Write-Host "Вывод всех значений 1й раз" -ForegroundColor Blue
$result1

Write-Host "Вывод всех значений 2й раз" -ForegroundColor Blue
$result2

Write-Host "Вывод всех значений 3й раз" -ForegroundColor Blue
$result3

Write-Host "Вывод всех значений 4й раз" -ForegroundColor Blue
$result4
<#
Browse for an entry with Display name “VMWare tools” and remove the complete branch under
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall

For Test #1
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{111111111h43gh3j4553h4jg5j32h4111111111}
Key:
{111111111h43gh3j4553h4jg5j32h4111111111}
Entries:
Test-entry1.1
Test-entry1.2
Properties:
VMWare tools

Browse for an entry with Display name “VMWare tools” and remove the complete branch under
HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products

For Test #2
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\22222222h43gh3j4553h4jg5j32h4222222
Key:
22222222h43gh3j4553h4jg5j32h4222222
Entries:
Test-entry2.1
Test-entry2.2
Properties:
VMWare tools

Browse for an entry with Display name “VMWare tools” and remove the complete branch under
HKEY_CLASSES_ROOT\Installer\Products

For Test #3
Computer\HKEY_CLASSES_ROOT\Installer\Products\55555555h43gh3j4553h4jg5j32h4555555
Key:
55555555h43gh3j4553h4jg5j32h4555555
Entry:
Test-entry3.1
Test-entry3.2
Property:
VMWare tools

Browse for an entry with Display name “VMWare tools” and remove the complete branch under
HKEY_LOCAL_MACHINE\Software\VMware

For test #4
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\VMware\
Key:
VMWare tools
Entry:
    Test-entry4
Property:
Это тестовый Key

#>
