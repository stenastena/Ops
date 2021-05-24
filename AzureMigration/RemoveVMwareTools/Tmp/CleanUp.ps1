# Get version of the Powershell
## Get-Host | Select-Object Version

# Showing a Windows registry branch without diving to depth 
# Get-ChildItem -Path hkcu:\

# Showing a Windows registry branch without diving to depth and showing only top subbranches names 
# Get-ChildItem -Path hkcu:\ | Select-Object Name

# Showing a Windows registry branch without diving to depth and showing only top subbranches names. Using an approach with variable object.
# Get-ChildItem -Path Registry::HKEY_CURRENT_USER | Select-Object Name
##$psvar = Get-ChildItem -Path Registry::HKEY_CURRENT_USER
#Write-Host $psvar.Name #This approach doesn't show line breaks
##Write-Output $psvar.Name #This approach shows line breaks


# Showing a Windows registry branch -with- diving to depth and showing only top subbranches names.
#$psvar = Get-ChildItem -Path Registry::HKEY_CURRENT_USER -Recurse
#Write-Output $psvar.Name > c:\tmp\1.txt

# Showing a Windows registry branches -with- diving to depth and showing those that include some part of phrase.
#Get-ChildItem -Path Registry::HKEY_CURRENT_USER -Recurse | where {$_.Name -like "*FaxBeep"}

# Showing a properties of Windows registry key. Where the key is used by its name. 
#Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\AppEvents\EventLabels\FaxBeep -Name DispFileName

# Showing all keys in a Windows registry branch. 
$psvar = Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Control Panel\Colors' 
Write-Output $psvar

#| Where-Object ($_.name -like "*240*")

#Get-ItemPropertyValue -Path Registry::HKEY_CURRENT_USER\AppEvents\EventLabels\FaxBeep -Name "DispFileName"

