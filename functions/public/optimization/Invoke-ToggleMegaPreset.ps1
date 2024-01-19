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

    $checkBoxNames = "Telemetry", "Wifi", "AH", "DeleteTempFiles", "RecycleBin", "DiskCleanup", "LocTrack", "Storage", "Hiber", "DVR", 
                    "CoreIsolation", "DisableTeredo", "AutoAdjustVolume", "Power", "Display", "RemoveCortana", "RemoveWidgets", "DisableNotifications", 
                    "RightClickMenu", "DisableUAC", "ClassicAltTab", "WindowsSound", "Personalize", "ModernCursorLight"
    $checkBoxes = $checkBoxNames | ForEach-Object { $tabItem.FindName("Dbl$_") }

    foreach ($checkBox in $checkBoxes) {
        $checkBox.IsChecked = $IsChecked
    }

    if ($IsChecked) { Write-Host "Enabling Mega Preset" -ForegroundColor Green } else { Write-Host "Disabling Mega Preset" -ForegroundColor Red }
}