function Invoke-ChocoUninstall {

    <#

    .SYNOPSIS
        Unistalling chocolatey
    #>

    if ((Get-Command -Name choco -ErrorAction Ignore) -and (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion) {
        Write-Host "Uninstalling chocolatey package" -ForegroundColor Red
        $chocoPath = $env:ChocolateyInstall
        # Remove the folder
        Remove-Item -Path $chocoPath -Recurse -Force
        # Specify the name of the environment variable you want to remove
        $chocoEnv = "ChocolateyInstall"
        $chocoUpdateEnv = "ChocolateyLastPathUpdate"
        # Remove the environment variable
        [Environment]::SetEnvironmentVariable($chocoEnv, $null, [System.EnvironmentVariableTarget]::Machine)
        [Environment]::SetEnvironmentVariable($chocoUpdateEnv, $null, [System.EnvironmentVariableTarget]::User)
        Invoke-MessageBox -msg "uninstall"
    }else{
        Write-Host "Seems Chocolatey is not installed" -ForegroundColor Red
    }
}