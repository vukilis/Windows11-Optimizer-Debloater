function Invoke-ToggleMegaPreset {
    <#

    .SYNOPSIS
        Mega preset to help when tweaking  
    #>

    $IsChecked = $wpf_megaPresetButton.IsChecked

    $wpf_fastPresetButton.IsEnabled = !$IsChecked; $wpf_fastPresetButton.Style = $wpf_fastPresetButton.TryFindResource(('ToggleSwitchStyle' + ('Green', 'Disabled')[$IsChecked]))

    $tabItemName = "Tab4"
    $tabItem = $psform.FindName($tabItemName)

    if ($tabItem -eq $null) {
        Write-Host "TabItem not found"
        return
    }

    $checkBoxNames = "Telemetry", "Wifi", "AH", "DeleteTempFiles", "DiskCleanup", "LocTrack", "Storage", "Hiber", "DVR",
                    "Power", "Display", "RemoveCortana", "RightClickMenu", "DisableUAC", "Personalize"
    $checkBoxes = $checkBoxNames | ForEach-Object { $tabItem.FindName("Dbl$_") }

    foreach ($checkBox in $checkBoxes) {
        $checkBox.IsChecked = $IsChecked
    }

    if ($IsChecked) { Write-Host "Enabling Fast Preset" -ForegroundColor Green } else { Write-Host "Disabling Fast Preset" -ForegroundColor Red }
}