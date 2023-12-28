function Invoke-FixesWinget {

    <#

    .SYNOPSIS
        This would install the latest version of winget and install it with its dependency's
    #>

    Write-Host "Installing winget" -ForegroundColor Green
    $winget = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Start-Process -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Add-AppxPackage -Path '$winget'" -NoNewWindow -Wait

    Invoke-MessageBox -msg "install"
}