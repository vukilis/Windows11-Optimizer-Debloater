<#
.NOTES
    Author         : Vuk1lis
    Website        : https://vukilis.com
    GitHub         : https://github.com/vukilis
    Name:          : Windows11 Optimizer&Debloater
    Version        : 4.0
#>

#requires -Version 7.0
Set-StrictMode -Version Latest

# Self-elevate if not running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $PSCommandPath
        $psi.Arguments = $args -join ' '
        $psi.Verb = 'runas'
        $psi.UseShellExecute = $true
        try {
            [System.Diagnostics.Process]::Start($psi) | Out-Null
        } catch {
            Write-Warning "Administrator elevation was cancelled or failed. The application may not work correctly."
        }
        exit
    } else {
        Write-Warning "Script was invoked from memory (e.g., via iex). Cannot self-elevate. Please restart as administrator."
    }
}

Add-Type -AssemblyName PresentationFramework

Start-Transcript $ENV:TEMP\win11deb.log -Append

$ScriptVersion = "4.0 - 28.08.2026"