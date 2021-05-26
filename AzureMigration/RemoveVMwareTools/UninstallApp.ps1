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
$app = Get-Package |  Where-Object {$_.Name -like "*zip*" } | Select-Object Name 
Write-Output $app.Name