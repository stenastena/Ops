# If this script doesn't work due the Execution policy restrictions, perform these two commands from the Powshershell console
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
#Unblock-File -Path .\CleanRegVmTools.ps1

function Search-Registry { 
    <# 
    This function can search registry key names, value names, and value data (in a limited fashion). 
    It outputs custom objects that contain the key and the first match type (KeyName, ValueName, or ValueData). 
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
                                Return $Key
                            }  
                        } 
    
                        if ($ValueNameRegex) 
                        {  
                            if ($Key.GetValueNames() -match $ValueNameRegex) 
                            {  
                                Return $Key
                            }  
                        } 
    
                        if ($ValueDataRegex) 
                        {  
                            if (($Key.GetValueNames() | % { $Key.GetValue($_) }) -match $ValueDataRegex) 
                            {  
                                Return $Key
                            } 
                        } 
                    } 
            } 
        } 
    } 
    
# =========== First of all, we try to remove Vmware Tools with standard tools and with different ways depending on the operation system
<#
if ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "2012"  ) {
    Write-Host "Windows Server 2012"    
    #Uninstall VMtools from Win Server 2012
    $regpath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\uninstall"
    Get-childItem $regpath | %  {
    $keypath = $_.pschildname
    $key = Get-Itemproperty $regpath\$keypath
    if ($key.DisplayName -match "VMware Tools") {
    $VMwareToolsGUID = $keypath
    }
    #Write-Output $VMwareToolsGUID
    }
    #MsiExec.exe /x $VMwareToolsGUID  /qn /norestart
    #Wait-Job -Any
}
        
elseif ( ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "2016") -or `
    ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "Windows 10") -or `
    ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "2019")  ) { 
    Write-Host "Win 2016 or 2019 or Win 10"
    #Uninstall VMtools from Win Server 2016
    $regpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $regkey = $regpath | Get-ChildItem | Get-ItemProperty | Where-Object { 'VMware Tools' -contains $_.DisplayName }
    msiexec.exe /x $regkey.PSChildName /passive /norestart
    #Wait-Job -Any
    Start-Job -Name RemoveVMtoolsByStandardTool -ScriptBlock {$(msiexec.exe /x $regkey.PSChildName  /passive /norestart)} | Wait-Job
}
else {
    Write-Host "There is another operation system:"
    (Get-WmiObject -class Win32_OperatingSystem).Caption | Write-Host 
}

#>

# =========== Often, standard tools don't remove VMware Tools. Therefore, we are cleaning out the Windows registry and then remove VMware services  ===========
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
    Write-Host "2. Seach property in HKEY_LOCAL_MACHINE\Software\Classes\Installer\Features" -ForegroundColor Green
    $FullKeyPath = Search-Registry -Path "Registry::HKEY_LOCAL_MACHINE\Software\Classes\Installer\Features" -ValueDataRegex "VMWare tools" -ErrorAction Stop
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

    
    # =========== deleting service VMware Tools ===========
    cmd.exe /c "sc delete vmtools"
    cmd.exe /c "sc delete VGAuthService"
    # Also delete VMware Snapshot Provider
    #C:\Windows\system32\dllhost.exe /Processid:{9213D05C-8856-4518-BAA0-B04BA6C797A7}
    cmd.exe /c "sc delete vmvss"
    #Also delete VMware SVGA Helper Service
    #C:\Windows\system32\vm3dservice.exe
    cmd.exe /c "sc delete vm3dservice"

    # =========== Stop current VMware Tools processes ===========
    Stop-Process -Name "vmtoolsd" -Confirm:$false -Force
    Stop-Process -Name "VGAuthService" -Confirm:$false -Force
    
    # =========== deleteing folder with VMware Tools ===========
    try {
    Write-Host "Deleteng C:\Program Files\VMware\VMware Tools"
    Write-Host "Waiting about 5 sec..."
    Start-Sleep -Seconds 5
    Remove-Item "$Env:Programfiles\VMware\VMware Tools" -Force -Recurse -Confirm:$false -ErrorAction Stop
    }
    catch {
    Write-Host "Probably, can't delete some files, because their are busy. It could be done after restarting server." -ForegroundColor DarkYellow
    }
