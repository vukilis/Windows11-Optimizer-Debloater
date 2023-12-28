function Invoke-ChocoInstall {
    <#

    .SYNOPSIS
        Installing chocolatey
    #>

    #Check if chocolatey is installed and get its version
    if ((Get-Command -Name choco -ErrorAction Ignore) -and ($chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion)) {
        Write-Host "Chocolatey Version $chocoVersion is already installed" -ForegroundColor Green
    }else {
        Write-Host "Seems Chocolatey is not installed, installing now" -ForegroundColor Magenta
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        powershell choco feature enable -n allowGlobalConfirmation
    }
    Invoke-MessageBox -msg "install"
}