
if ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "2012"  ) {
    Write-Host "Win 2012"    
    }
    elseif ( ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "2016") -or `
    ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "Windows 10") -or `
    ((Get-WmiObject -class Win32_OperatingSystem).Caption -Match "2019")  ) { 
    Write-Host "Win 2016 or 2019 or Win 10"    
    }
    else {
    (Get-WmiObject -class Win32_OperatingSystem).Caption | Write-Host 
    }

