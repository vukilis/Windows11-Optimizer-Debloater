<#
.SYNOPSIS
    Speed Test Script:
        Mesaures the time it takes for a GUI application to start up. This script is useful for testing the startup time of scripts that launch GUI applications, such as PowerShell scripts that use WPF or WinForms.
        Required PowerShell 7.0 or higher.

    For a local file
        .\speed-test.ps1 -Target ".\win11deb.ps1"

    For a remote URL
    .\speed-test.ps1 -Target "vukilis.com/win11dev" -IsUrl
#>
param(
    [Parameter(Mandatory)]
    [string]$Target,
    
    [switch]$IsUrl
)

$argumentList = if ($IsUrl) {
    "-Command", "iwr -useb $Target | iex"
} else {
    "-File", $Target
}

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$process = Start-Process pwsh.exe -ArgumentList $argumentList -PassThru

do {
    Start-Sleep -Milliseconds 100
    $process.Refresh()
} while (-not $process.MainWindowTitle -or $process.MainWindowTitle -match "powershell|cmd|windows powershell|pwsh")

$stopwatch.Stop()
Write-Host "GUI startup time for $Target : $($stopwatch.ElapsedMilliseconds) ms" -ForegroundColor Green