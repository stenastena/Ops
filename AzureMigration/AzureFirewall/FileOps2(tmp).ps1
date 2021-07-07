
$a = Get-Process 

$b = New-Object System.Data.DataTable
$b = $a | Select-Object -first 5 'CPU'

Write-Output "+++++++++a:"
$a
Write-Output "---------a is memebr of:"
$a | Get-Member

Write-Output "---------b:" 
$b
Write-Output "---------b is memebr of:"
$b | Get-Member

#Write-Output "val:"
#$val

#$val | Get-Member

#$val2 = $val


#$val | Select-Object -Last 5  # -Unique

#Write-Output "val2:"
#$val2

#$val2 | Get-Member

<#
$val2
Write-Host "####################"

$lav

Write-Host "####################++++++++++++++++"
$lav3
#>

#Get-Service -ServiceName 'BITS' | Get-Member -MemberType Property
