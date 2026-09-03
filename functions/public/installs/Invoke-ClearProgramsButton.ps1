function Invoke-ClearProgramsButton {
    <#

    .SYNOPSIS
        Clear selected apps   
    #>
    
    $presets = @($wpf_ToggleLitePreset, $wpf_ToggleDevPreset, $wpf_ToggleGamingPreset)
    $styles = @("ToggleSwitchStyleGreen", "ToggleSwitchStylePurple", "ToggleSwitchStyleBlue")

    for ($i = 0; $i -lt $presets.Count; $i++) {
        $presets[$i].IsEnabled = $true
        $presets[$i].IsChecked = $false
        $presets[$i].Style = $presets[$i].TryFindResource($styles[$i])
    }

    $matchingProgram = Invoke-APPX | Where-Object { $_.IsChecked}

    foreach ($program in $matchingProgram) {
        $checkBox = $script:DynamicAppCheckBoxes[$program.Id]
        if ($checkBox) {
            $checkBox.IsChecked = $false
        }
    }
    Write-Host "Selection cleared" -ForegroundColor Green
}

