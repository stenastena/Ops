$ipgroup_prd_azure_globall = "10.64.0.0/24"

# The array of address and mask. 
# An example 10.64.0.0 and 24 
$address = @()
$address = $ipgroup_prd_azure_globall -split "/"

Write-Host " "
Write-Host "Number of hosts in the subnet:"
$NumberOfHost=[Math]::Pow(2,(32-$address[1]))
$NumberOfHost

Write-Host " "
Write-Host "The first host:"
$Host1st = $address[0]
$Host1st



#Divide the address fot the octets
$octets = @()
$octets = $address[0] -split  "\."
Write-Host " "
Write-Host "Octets:"
$octets
Write-Host " "
