function Get-ToggleStatus {
    <#
    .SYNOPSIS
        Initializes ToggleButtons based on registry or DefaultState.
    .OUTPUTS
        Boolean
    #>

    # Loop all tweak entries
    foreach ($key in $sync.configs.tweaks.PSObject.Properties.Name) {
        $entry = $sync.configs.tweaks.$key
        if ($entry.Type -ne "Toggle") { continue }

        $control = $psform.FindName($key)
        if (-not $control -or $control -isnot [System.Windows.Controls.Primitives.ToggleButton]) { continue }

        $isChecked = $null  # Start as null to distinguish "unset"

        if ($entry.registry -and $entry.registry.Count -gt 0) {
            foreach ($regEntry in $entry.registry) {
                try {
                    if (-not (Test-Path $regEntry.Path)) { New-Item -Path $regEntry.Path -Force | Out-Null }
                    $regValue = (Get-ItemProperty -Path $regEntry.Path -ErrorAction SilentlyContinue).$($regEntry.Name)

                    if ($regValue -eq $regEntry.Value) { $isChecked = $true }
                    elseif ($regValue -eq $regEntry.OriginalValue) { $isChecked = $false }

                    # If $isChecked is set, stop checking further
                    if ($isChecked -ne $null) { break }
                } catch { }
            }
        }

        # If still null, fallback to DefaultState
        if ($isChecked -eq $null -and $entry.registry -and $entry.registry[0].PSObject.Properties.Name -contains "DefaultState") {
            $defaultState = $entry.registry[0].DefaultState
            $isChecked = ($defaultState -eq $true -or $defaultState -eq "true")
        }

        # Ensure a boolean value
        $control.IsChecked = [bool]$isChecked
        # Write-Host "Set '$key' toggle to $($control.IsChecked)" -ForegroundColor Green
    }
}

Get-ToggleStatus
