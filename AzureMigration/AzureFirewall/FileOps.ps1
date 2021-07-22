# The workload, network and server description

# The original on-premise server's IP address 
$OnPremIPAddress = "172.16.12.10"

$ipgroup_prd_azureadds_global = "10.64.4.4", "10.64.4.5", "10.66.4.4", "10.66.4.5","10.64.4.6", "10.64.4.7"
$ipgroup_prd_onpremadds_global = "172.16.12.100", "172.16.12.147", "172.16.14.220", "192.168.219.1", "192.168.51.7", "192.168.65.2"
$ipgroup_prd_onprem_global = "192.168.0.0/16", "172.16.0.0/16", "10.100.10.0/24", "10.20.30.0/24", "10.200.0.0/16", "10.201.0.0/16", "10.242.0.0/16", "145.254.22.0/24", "172.17.0.0/16", "172.18.0.0/16", "192.1.1.0/24", "192.1.2.0/24", "194.64.252.0/24", "194.88.162.0/23"
$ipgroup_prd_azure_globall = "10.64.0.0/12"

# The subnet where target server is located
$AzureSubnet = "10.64.44.9/28"

#Import dependencies
#$OriginalMatrix = New-Object System.Data.DataTable
#Write-Output "########## "
#Write-Output "Original matrix:"
$OriginalMatrix = Import-Csv -Path .\Com-matrix.csv -Header "Time slot","Source server name","Source IP","Source application","Source process","Destination server name","Destination IP","Destination application","Destination process","Destination port"
#$OriginalMatrix
#$OriginalMatrix | Get-Member


#$ports = New-Object System.Data.DataTable
Write-Output " "
Write-Output "+++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
#Write-Output "The number of unique destination ports:"
Write-Output "There are ports:"
$ports = $OriginalMatrix | Select-Object "Destination port"  -Unique #| Format-Table
$ports #| Format-Table
#$ports.Count

foreach ($port in $ports) {
    #$port

    #$filter = New-Object System.Data.DataTable
    Write-Output " "
    Write-Output "######################################################### "
    Write-Output "Filtering port: " $port.'Destination port'
    $filter = $OriginalMatrix | Select-Object "Source IP", "Destination IP", "Destination port" | Where-Object "Destination port" -eq $port.'Destination port'
    $filter | Format-Table
    #$filter | Get-Member

    #Write-Output " "
    #Write-Output "Outbound traffic for the current port:" + $port
    $AllOutbound = $filter | Where-Object "Source IP" -EQ $OnPremIPAddress
    
    #Write-Output " "
    #Write-Output "Inbound traffic for the port 49321:"
    $AllInbound = $filter | Where-Object "Destination IP" -EQ $OnPremIPAddress
    
    

    #Check outbound traffic for the current port
    if ($AllOutbound.Count -gt 0) {
        Write-Host "Output from:" $AzureSubnet " to: " $OnPremIPAddress " port: " $port.'Destination port'    
        
    }
    
    #Check inbound traffic for the current port
    if ($AllInbound.Count -gt 0) {
        Write-Host "Input from:" $OnPremIPAddress " to: " $AzureSubnet " port: " $port.'Destination port'    
        
    }

}

#$port | Get-Member

# For outbound rules
Write-Output " "
$NetworkruleName =  "Allow" + $port."Destination port" + "Outbound"


$DestinationIpGroup = "IpGroupYYY"
$networkrule1 = "New-AzFirewallNetworkRule -Name " + $NetworkruleName + `
" -SourceAddress "  + $AzureSubnet + " -DestinationIpGroup " + `
$DestinationIpGroup + " -DestinationPort " + $port."Destination port" + " -Protocol TCP, UDP"
$networkrule1


<#
Write-Output "These ports are:"
for ($i = 0; $i -lt $ports.Count; $i++) {
$ports[$i]    
}
#>


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
