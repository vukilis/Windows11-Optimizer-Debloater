function Invoke-OptimizationClear {
    Write-Host "Clearing all checkboxes in the optimization form..." -ForegroundColor Cyan
    
    $presets = @($wpf_fastPresetButton, $wpf_megaPresetButton)
    $styles = @("ToggleSwitchStyleGreen", "ToggleSwitchStylePurple")

    for ($i = 0; $i -lt $presets.Count; $i++) {
        $presets[$i].IsEnabled = $true
        $presets[$i].IsChecked = $false
        $presets[$i].Style = $presets[$i].TryFindResource($styles[$i])
    }

    foreach ($key in $sync.configs.tweaks.PSObject.Properties.Name) {
        $tweak = $sync.configs.tweaks.$key
        $ctrl  = $psform.FindName($key)

        if ($ctrl -is [System.Windows.Controls.CheckBox]) {
            if ($ctrl.IsChecked) {
                # Write-Host "Unchecking: $key" -ForegroundColor Yellow
                $ctrl.IsChecked = $false
            }
        }
    }
}
