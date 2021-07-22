<#
Open registry by running regedit

Search for following registry keys and ensure their value is set accordingly
HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\WinStationsDisabled
Value: String = 0


HKLM\System\CurrentControlSet\Control\Terminal Server\TSServerDrainMode
Value: Dword = 0 
#>
Write-Output "------------------------------------------------------------------------------------------------------ "
Write-Output "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\WinStationsDisabled should be = 0"
Write-Output "In reality:"
$regkey = Get-ItemProperty -Path "Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" #-Name WinStationsDisabled
if ($regkey.WinStationsDisabled -ne $null) {
Write-Host $regkey.WinStationsDisabled -ForegroundColor Green
} 
else {
Write-Host "There are no this registry key: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\WinStationsDisabled\WinStationsDisabled" -ForegroundColor Yellow
}

Write-Output " "
Write-Output "HKLM\System\CurrentControlSet\Control\Terminal Server\TSServerDrainMode should be = 0"
Write-Output "In reality:"
$regkey = Get-ItemProperty -Path "Registry::HKLM\System\CurrentControlSet\Control\Terminal Server" #-Name TSServerDrainMode
if ($regkey.TSServerDrainMode -ne $null) {
Write-Host $regkey.TSServerDrainMode -ForegroundColor Green
} 
else {
Write-Host "There are no this registry key: HKLM\System\CurrentControlSet\Control\Terminal Server\TSServerDrainMode" -ForegroundColor Yellow
}

