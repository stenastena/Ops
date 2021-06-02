# If this script doesn't work due the Execution policy restrictions, perform these two commands from the Powshershell console
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
    
    
    # -------- cleaning Windows registry ------------------
    try {
        Write-Host "1. Seach property in HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" -ForegroundColor Green
        $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"  -ValueDataRegex "VMWare tools" -ErrorAction Stop
        Write-Host "Found:"
        Write-Output $FullKeyPath | Get-Item -ErrorAction Stop
        foreach ($EachKey in $FullKeyPath) {
            Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
            Write-Output $EachKey | Remove-Item -Force -Recurse -Confirm:$false 
        }
        Write-Output ""     
    }
    catch {
        Write-Host "Probably, nothing found" -ForegroundColor DarkYellow    
        Write-Output ""
    }
    
    
    try {
        Write-Host "2. Seach property in HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products" -ForegroundColor Green
        $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Classes\Installer\Products" -ValueDataRegex "VMWare tools" -ErrorAction Stop
        Write-Host "Found:"
        Write-Output $FullKeyPath | Get-Item -ErrorAction Stop
        foreach ($EachKey in $FullKeyPath) {
            Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
            Write-Output $EachKey | Remove-Item -Force -Recurse -Confirm:$false 
        }    
        Write-Output ""
    }
    catch {
       Write-Host "Probably, nothing found" -ForegroundColor DarkYellow 
       Write-Output ""
    }
    
    
    try {
        Write-Host "3. Seach key in HKEY_LOCAL_MACHINE\Software\VMware, Inc." -ForegroundColor Green
        $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\VMware, Inc."  -KeyNameRegex "VMWare tools" -ErrorAction Stop
        Write-Host "Found:"
        Write-Output $FullKeyPath | Get-Item -ErrorAction Stop
        foreach ($EachKey in $FullKeyPath) {
            Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
            Write-Output $EachKey | Remove-Item -Force -Recurse -Confirm:$false 
        }    
        Write-Output ""
    }
    catch {
        Write-Host "Probably, nothing found" -ForegroundColor DarkYellow
        Write-Output ""
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
    
    
    try {
        Write-Host "4. Seach key in HKEY_LOCAL_MACHINE\Software\VMware Drivers" -ForegroundColor Green
        $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\VMware Drivers"  -KeyNameRegex "VMWare tools" -ErrorAction Stop
        Write-Host "Found:"
        Write-Output $FullKeyPath | Get-Item -ErrorAction Stop
        foreach ($EachKey in $FullKeyPath) {
            Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
            Write-Output $EachKey | Remove-Item -Force -Recurse -Confirm:$false
        }    
        Write-Output ""
    }
    catch {
        Write-Host "Probably, nothing found" -ForegroundColor DarkYellow
        Write-Output ""
    }
    
    try {
        Write-Host "5. Seach key in HKEY_LOCAL_MACHINE\Software\VMware VGAuth" -ForegroundColor Green
        $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\VMware VGAuth"  -KeyNameRegex "VMWare tools" -ErrorAction Stop
        Write-Host "Found:"
        Write-Output $FullKeyPath | Get-Item -ErrorAction Stop
        foreach ($EachKey in $FullKeyPath) {
            Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
            Write-Output $EachKey | Remove-Item -Force -Recurse -Confirm:$false 
        }    
        Write-Output ""
    }
    catch {
        Write-Host "Probably, nothing found" -ForegroundColor DarkYellow
        Write-Output ""
    }
    
    try {
        Write-Host "6. Seach key in HKEY_LOCAL_MACHINE\Software\VMwareHostOpen" -ForegroundColor Green
        $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\VMwareHostOpen"  -KeyNameRegex "VMWare tools" -ErrorAction Stop
        Write-Host "Found:"
        Write-Output $FullKeyPath | Get-Item -ErrorAction Stop
        foreach ($EachKey in $FullKeyPath) {
            Write-Host "Removing this key...$EachKey" -ForegroundColor Yellow
            Write-Output $EachKey | Remove-Item -Force -Recurse -Confirm:$false 
        }    
        Write-Output ""
    }
    catch {
        Write-Host "Probably, nothing found" -ForegroundColor DarkYellow
        Write-Output ""
    }
    
    # ---------------- deleting service VMware Tools
    #sc delete VMtools 
    #Remove-Service -Name VMtools
    
    cmd.exe /c "sc delete vmtools"
    cmd.exe /c "sc delete VGAuthService"
    
    #VMware Snapshot Provider
    #C:\Windows\system32\dllhost.exe /Processid:{9213D05C-8856-4518-BAA0-B04BA6C797A7}
    
    cmd.exe /c "sc delete vmvss"
    
    #VMware SVGA Helper Service
    #C:\Windows\system32\vm3dservice.exe
    
    cmd.exe /c "sc delete vm3dservice"
    
    
    
    # =========== deleteing folder with VMware Tools ---------------
    #Get-ChildItem "C:\Program Files\VMware\VMware Tools\" -Recurse | Remove-Item -Force -Confirm:$false 
    try {
    Write-Host "Deleteng C:\Program Files\VMware\VMware Tools..."
    Remove-Item "C:\Program Files\VMware\VMware Tools" -Force -Recurse -Confirm:$false -ErrorAction Stop
    }
    catch {
    Write-Host "Probably, can't delete some files, because their are busy. It could be done after restarting server." -ForegroundColor DarkYellow
    }
    
    
    
