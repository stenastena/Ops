#$download_url = "https://theitbros.com/wp-content/uploads/2018/08/cropped-logo_fon-1-2.png"
$download_url = "https://go.microsoft.com/fwlink/?LinkID=394789"
$local_path = "C:\tmp\WindowsAzureVmAgent.msi"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($download_url, $local_path)
#cmd.exe /c "sc delete vm3dservice"