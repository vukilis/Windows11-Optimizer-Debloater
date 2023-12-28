function Invoke-ChocoUpgrade {
    <#

    .SYNOPSIS
        Upgrading chocolatey
    #>

    if ((Get-Command -Name choco -ErrorAction Ignore) -and (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion) {
        Write-Host "Upgrading chocolatey package" -ForegroundColor Blue
        Start-Process -FilePath choco -ArgumentList "upgrade chocolatey -y" -NoNewWindow -Wait
        Invoke-MessageBox -msg "upgrade"
    }else{
        Write-Host "Seems Chocolatey is not installed" -ForegroundColor Red
    }
}