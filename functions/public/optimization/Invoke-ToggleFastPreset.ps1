function Invoke-ToggleFastPreset {
    <#

    .SYNOPSIS
        Fast preset to help when tweaking  
    #>

    $IsChecked = $wpf_fastPresetButton.IsChecked

    $wpf_megaPresetButton.IsEnabled = !$IsChecked; $wpf_megaPresetButton.Style = $wpf_megaPresetButton.TryFindResource(('ToggleSwitchStyle' + ('Purple', 'Disabled')[$IsChecked]))

    $tabItemName = "Tab4"
    $tabItem = $psform.FindName($tabItemName)

    if ($tabItem -eq $null) {
        Write-Host "TabItem not found"
        return
    }

    $checkBoxNames = "Telemetry", "Wifi", "AH", "DeleteTempFiles", "LocTrack", "Storage", "Hiber", "DVR", "Power", "Display", "Personalize"
    $checkBoxes = $checkBoxNames | ForEach-Object { $tabItem.FindName("Dbl$_") }

    foreach ($checkBox in $checkBoxes) {
        $checkBox.IsChecked = $IsChecked
    }

    if ($IsChecked) { Write-Host "Enabling Fast Preset" -ForegroundColor Green } else { Write-Host "Disabling Fast Preset" -ForegroundColor Red }
}