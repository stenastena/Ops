<#
$apps = Get-AppxPackage | Select-Object Name, PackageFullName  
# | Where-Object {$_.Name -contains "Wallet" }
Write-host ""
Write-host ""
#Write-Output $apps 
Where-Object {$apps.Name -contains "Wallet" }
#>

<#
$apps = Get-AppxPackage 
Write-Output $apps.Name | Where-Object {$_ -like "*zip" }
#>
<#
Get-WmiObject -Class Win32_Product | Select-Object -Property Name #| Where-Object {$_ -like "*zip" } 
Write-Output "---------------"
Get-AppxPackage | Select-Object Name #| Where-Object {$_ -like "*zip" }
Write-Output "---------------"
#>


# Powershell 5.0 and above
#$app = Get-Package |  Where-Object {$_.Name -like "*zip*" } | Select-Object Name 
#Write-Output $app.Name

#$app = Get-Package |  Where-Object {$_.Name -like "*zip*" } | Select-Object Name 
#Write-Output $app.Name

#Uninstall VMtools from Win Server 2012
$regpath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\uninstall"
Get-childItem $regpath | %  {
$keypath = $_.pschildname
$key = Get-Itemproperty $regpath\$keypath
if ($key.DisplayName -match "VMware Tools") {
$VMwareToolsGUID = $keypath
}
Write-Output $VMwareToolsGUID
}
#MsiExec.exe /x $VMwareToolsGUID  /qn /norestart

#error code of last windows app
Write-Output "Tha last app was finished with this code: $?" 

#error code of last Pwershell commandlet
Write-Output "Tha last Pwershell commandlet was finished with this code: $LastExitCode" 

