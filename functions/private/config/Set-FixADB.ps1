function Invoke-FixADB {
    <#

    .SYNOPSIS
        This script will find install location of ADB and set environment. 
    #>

    #[Environment]::SetEnvironmentVariable('PATH', ([Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User) + ';C:\Users\winget\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools'), [System.EnvironmentVariableTarget]::User)

    $filePath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
    $jsonContent = Get-Content -Path $filePath | Out-String
    $jsonObject = ConvertFrom-Json $jsonContent
    if ($jsonObject.installBehavior.PSObject.Properties.Name -contains 'portablePackageUserRoot') {
        $portablePackageUserRoot = $jsonObject.installBehavior.portablePackageUserRoot -replace '/', '\'
        #Write-Output "portablePackageUserRoot: $portablePackageUserRoot"
        $targetPath = "$portablePackageUserRoot\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools"
    } else {
        $targetPath = "%LOCALAPPDATA%\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools"
        #Write-Output "portablePackageUserRoot property does not exist in the JSON file."
    }

    $userPath = [Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)

    # Check if the path is already in the user's PATH
    if ($userPath -notlike "*$targetPath*") {
        # Append the path to the end if it doesn't exist
        [Environment]::SetEnvironmentVariable('PATH', "$userPath;$targetPath", [System.EnvironmentVariableTarget]::User)
        #Write-Host "Path added to the user's PATH variable." -ForegroundColor Green
        Art -artN "
=============================================
-- Path added to the user's PATH variable. --
=============================================
" -ch DarkGreen
    } else {
        #Write-Host "Path is already present in the user's PATH variable." -ForegroundColor Magenta
        Art -artN "
==========================================================
-- Path is already present in the user's PATH variable. --
==========================================================
" -ch Magenta
    }
    
    Invoke-MessageBox -msg "tweak"
    
}
