function Invoke-ManageInstall {
    <#

    .SYNOPSIS
        Handler function for installing, uninstalling and upgrading apps
        Invoke-ManageInstall -PackageManger "winget" -manage "Installing" -program $name -PackageName $winget
    #>

    param(
            $program,
            $PackageManger,
            $PackageName,
            $manage 
        )

    if($manage -eq "Installing" -and $PackageManger -eq "pip"){
        if (Get-Command python -ErrorAction Ignore) {
            Write-Host "Installing $name package" -ForegroundColor Green
            python -m pip install --no-input --quiet --upgrade pip
            pip install $PackageName --no-input --quiet 
        } else {
            Write-Host "Python is not installed." -ForegroundColor Red
        }
    }elseif($manage -eq "Installing" -and $PackageManger -eq "winget"){
        Write-Host "Installing $name package" -ForegroundColor Green
        Start-Process -FilePath winget -ArgumentList "install --id $PackageName -e --accept-source-agreements --accept-package-agreements --disable-interactivity --silent" -NoNewWindow -Wait
    }elseif($manage -eq "Installing" -and $PackageManger -eq "choco"){
        if ((Get-Command -Name choco -ErrorAction Ignore) -and (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion) {
            Write-Host "Installing $name package" -ForegroundColor Green
            Start-Process -FilePath choco -ArgumentList "install $PackageName -y" -NoNewWindow -Wait
        }else{
            Write-Host "Seems Chocolatey is not installed" -ForegroundColor Red
        }
    }

    if($manage -eq "Uninstalling" -and $PackageManger -eq "pip"){
        if (Get-Command python -ErrorAction Ignore) {
            Write-Host "Uninstalling $name package" -ForegroundColor Red
            pip uninstall $PackageName --yes --quiet --no-input
        } else {
            Write-Host "Python is not installed." -ForegroundColor Red
        }
    }elseif($manage -eq "Uninstalling" -and $PackageManger -eq "winget"){
        Write-Host "Uninstalling $name package" -ForegroundColor Red
        Start-Process -FilePath winget -ArgumentList "uninstall --id $PackageName -e --purge --force --disable-interactivity --silent" -NoNewWindow -Wait
    }elseif($manage -eq "Uninstalling" -and $PackageManger -eq "choco"){
        if ((Get-Command -Name choco -ErrorAction Ignore) -and (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion) {
            Write-Host "Uninstalling $name package" -ForegroundColor Red
            Start-Process -FilePath choco -ArgumentList "uninstall $PackageName -y" -NoNewWindow -Wait
        }else{
            Write-Host "Seems Chocolatey is not installed" -ForegroundColor Red
        }
    }

    if($manage -eq "Upgrading" -and $PackageManger -eq "pip"){
        if (Get-Command python -ErrorAction Ignore) {
            Write-Host "Upgrading $name package" -ForegroundColor Blue
            pip install --upgrade $PackageName --no-input --quiet --no-cache
        } else {
            Write-Host "Python is not installed." -ForegroundColor Red
        }
    }elseif($manage -eq "Upgrading" -and $PackageManger -eq "winget"){
        Write-Host "Upgrading $name package" -ForegroundColor Blue
        Start-Process -FilePath winget -ArgumentList "upgrade --id $PackageName -e --accept-source-agreements --accept-package-agreements --disable-interactivity --silent --force" -NoNewWindow -Wait
    }elseif($manage -eq "Upgrading" -and $PackageManger -eq "choco"){
        if ((Get-Command -Name choco -ErrorAction Ignore) -and (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion) {
            Write-Host "Upgrading $name package" -ForegroundColor Blue
            Start-Process -FilePath choco -ArgumentList "upgrade $PackageName -y" -NoNewWindow -Wait
        }else{
            Write-Host "Seems Chocolatey is not installed" -ForegroundColor Red
        }
    }
}