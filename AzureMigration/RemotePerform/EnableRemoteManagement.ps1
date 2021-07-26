#Enable-PSRemoting
Enable-PSRemoting -Force
winrm set winrm/config/client  '@{TrustedHosts="192.168.70.1"}'
#winrm set winrm/config/client  '@{TrustedHosts="*"}'
#winrm set winrm/config/client  '@{TrustedHosts="DESKTOP-0M1GI4N"}'
#Set-Item wsman:\localhost\client\trustedhosts *

Restart-Service WinRM