# The workload, network and server description
$OnPremIPAddress = "172.16.12.51"

#Import dependencies
#$OriginalMatrix = New-Object System.Data.DataTable
Write-Output "########## "
Write-Output "Original matrix:"
$OriginalMatrix = Import-Csv -Path .\Com-matrix.csv -Header "Time slot","Source server name","Source IP","Source application","Source process","Destination server name","Destination IP","Destination application","Destination process","Destination port"
#$OriginalMatrix
#$OriginalMatrix | Get-Member


#$ports = New-Object System.Data.DataTable
Write-Output "########## "
Write-Output "Unique destination ports:"
$ports = $OriginalMatrix | Select-Object "Destination port"  -Unique #| Format-Table
$ports | Format-Table
#$ports | Get-Member

#$filter = New-Object System.Data.DataTable
Write-Output "########## "
Write-Output "Filtering by 49321 port:"
$filter = $OriginalMatrix | Select-Object "Source IP", "Destination IP", "Destination port" | Where-Object "Destination port" -eq 49321 #| Format-Table
$filter | Format-Table
#$filter | Get-Member




<# Complicated approach
foreach ($connection in $matrix) 
{
    try 
    {    
        Write-host "Source IP=" $connection.'Source IP' "Destination IP=" $connection.'Destination IP' "Target port=" $connection.'Destination port' 
        
        
    }
    catch
    {
        Write-Host "Something wrong" -ForegroundColor Yellow
        Write-Host "..." -ForegroundColor Green    
    }
}
#>

#Other approach

<#The entire  file filtered by some columns
Write-Output "Without filtering:"

$matrix | Select-Object "Source IP", "Destination IP", "Destination port"
#>