try {
    Get-Content -Path ″C:\Files\*″ -ErrorAction Stop
    }
    catch [System.UnauthorizedAccessException]
    {
    Write-Host ″File is not accessible.″
    }
    catch {
    Write-Host ″Other type of error was found:″
    Write-Host ″Exception type is $($_.Exception.GetType().Name)″
    }
    finally {
    Write-Host ″Finish.″
    }

    <#
    Get-Content -Path ″C:\Files\*″ -ErrorAction Stop
    Write-Output "Gjckt jib,rb"
    #>