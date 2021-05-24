<#
# Export to file
$VMList = ConvertFrom-Csv @'
OldName,        NewName,        OS
VmNewWin22,     VmNewWin2222,   Windows
VmNewLin000,    VmLin0,         Linux
VmNewLin11,     VmLin1,         Linux
VmNewWin2,      VmWin2,         Windows
'@

$VMList | Export-Csv -Path .\VMs.csv

#>

$VMList = Import-Csv -Path .\VMs.csv
$VMList