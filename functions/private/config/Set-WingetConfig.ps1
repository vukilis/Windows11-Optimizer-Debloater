function Set-WingetConfig {
    <#

    .SYNOPSIS
        This function will setup winget configuration. 
    #>

    $jsonContent = @'
{
    "$schema": "https://aka.ms/winget-settings.schema.json",
    "visual": {
        "progressBar": "rainbow"
    },
    "installBehavior": {
        "preferences": {
            "locale": [ "en-US" ]
        },
        "portablePackageUserRoot": "C:/Users/winget/Packages",
        "portablePackageMachineRoot": "C:/Program Files/winget/Packages"
    },
    "telemetry": {
        "disable": true
    },
    "logging": {
        "level": "error"
    }
}
'@

    $filePath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
    $jsonContent | Set-Content -Path $filePath
    Art -artN "
====================================
-- WinGet settings are configured --
====================================
" -ch DarkGreen
    Invoke-MessageBox -msg "tweak"
}