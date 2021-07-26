#cd C:\Users\serge\Documents\_Work\Code\AzureMigration\RemotePerform\
#winrm set winrm/config/client  '@{TrustedHosts="192.168.70.130"}'
####winrm set winrm/config/client  '@{TrustedHosts="WIN2016-1"}'
#Restart-Service WinRM

#$cred=Get-Credential
$sess = New-PSSession -Credential $cred -ComputerName 192.168.70.130
#$sess = New-PSSession -Credential $cred -ComputerName WIN2016-1

# If you want to use interactive session
#Enter-PSSession $sess

#Performing script remotely 
Invoke-Command -FilePath .\ScriptForRemote.ps1  -Session $sess   #-ComputerName Server01 

# Copying agents to the target VM
#Copy-Item "C:\Users\serge\Documents\_Work\Migrations\Agents\" -Destination "C:\AzureMig\Agents\" -ToSession $sess -Recurse

# Copying files from remote VM
Copy-Item "C:\azuremig\removevmtools.ps1" -Destination "C:\tmp\" -FromSession $sess 



#$myhost = hostname
#Write-Output "Hostname is:" $myhost 

##mkdir c:\1234

# Using along command
#Invoke-Command -ScriptBlock { Test-WsMan 192.168.70.130} -Session $sess

# If you used interactive session
#Exit-PSSession

Remove-PSSession $sess

#Test remote management
#Test-WsMan WIN2016-1
#Test-WsMan 192.168.70.130