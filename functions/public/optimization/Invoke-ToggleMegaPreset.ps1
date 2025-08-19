function Invoke-ToggleMegaPreset {
    param(
        [switch]$IsChecked  # Optional: allows forcing check/uncheck
    )

    $tweak = $sync.configs.preset.megaPresetButton
    # Write-Host "Found $($tweak.Count) checkboxes: $($tweak -join ', ')"

    # Determine the toggle state for Mega Preset
    $IsChecked = if ($PSBoundParameters.ContainsKey('IsChecked')) { $IsChecked } else { $wpf_megaPresetButton.IsChecked }
    
    # Enable/disable the fast preset button depending on state
    $wpf_fastPresetButton.IsEnabled = -not $IsChecked
    $styleName = ('ToggleSwitchStyleDisabled', 'ToggleSwitchStyleGreen')[[int](-not $IsChecked)]
    $styleResource = $wpf_fastPresetButton.TryFindResource($styleName)
    if ($styleResource -and $styleResource.TargetType -eq [System.Windows.Controls.Primitives.ToggleButton]) {
        $wpf_fastPresetButton.Style = $styleResource
    } else {
        Write-Warning "Style '$styleName' not found or incompatible with ToggleButton."
    }

    # Find the tab containing the checkboxes
    $tabItemName = "Tab4"
    $tabItem = $psform.FindName($tabItemName)

    if ($tabItem -eq $null) {
        Write-Host "TabItem '$tabItemName' not found"
        return
    }

    $checkBoxes = $tweak | ForEach-Object { $tabItem.FindName($_) }

    # Set all checkboxes to the same state as Mega Preset
    foreach ($checkBox in $checkBoxes) {
        if ($checkBox -ne $null) {
            $checkBox.IsChecked = $IsChecked
        } else {
            # Write-Warning "Checkbox '$_' not found in Tab4"
        }
    }

    # Log status
    if ($IsChecked) { 
        Write-Host "Enabling Mega Preset" -ForegroundColor Green 
    } else { 
        Write-Host "Disabling Mega Preset" -ForegroundColor Red 
    }
}