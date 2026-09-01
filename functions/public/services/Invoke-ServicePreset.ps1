function Invoke-ServicePreset {
    <#
    .SYNOPSIS
        Apply a service preset from config/services.json
    .PARAMETER Mode
        The preset mode: recommended, gaming, or default
    #>
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("recommended","gaming","default")]
        [string]$Mode
    )

    $preset = $services.$Mode
    if (-not $preset) {
        Write-Warning "Service preset '$Mode' not found in services.json"
        return
    }

    foreach ($type in $preset.PSObject.Properties.Name) {
        foreach ($svc in $preset.$type) {
            Write-Host "Setting $svc StartupType to $type" -ForegroundColor Yellow
            Get-Service -Name $svc -ErrorAction SilentlyContinue | Set-Service -StartupType $type -ErrorAction SilentlyContinue
        }
    }

    $modeName = $Mode.Substring(0,1).ToUpper() + $Mode.Substring(1)
    Art -artN "
======================================
----- Services set to $modeName Mode -----
======================================
" -ch Cyan
    Invoke-MessageBox "tweak"
}
