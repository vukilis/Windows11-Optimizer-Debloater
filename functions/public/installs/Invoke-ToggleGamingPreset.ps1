function Invoke-ToggleGamingPreset {
    <#

    .SYNOPSIS
        Gaming preset to help when installing apps   
    #>

    $IsChecked = $wpf_ToggleGamingPreset.IsChecked
    $wpf_ToggleLitePreset.IsEnabled = !$IsChecked; $wpf_ToggleLitePreset.Style = $wpf_ToggleLitePreset.TryFindResource(('ToggleSwitchStyle' + ('Green', 'Disabled')[$IsChecked]))
    $wpf_ToggleDevPreset.IsEnabled = !$IsChecked; $wpf_ToggleDevPreset.Style = $wpf_ToggleDevPreset.TryFindResource(('ToggleSwitchStyle' + ('Purple', 'Disabled')[$IsChecked]))

    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $checkBox = $psform.FindName($program.Id)
        $isChecked = $checkBox.IsChecked

        if ($checkBox.IsChecked -eq $false -and @(
            "Git", "Dotnet3", "Dotnet5", "Dotnet6",
            "Dotnet7", "vc2015_64", "vc2015_32", "Thorium",
            "Discord", "Eaapp", "Epicgames", "Steam",
            "Ubisoft", "Greenshot", "Imageglass", "Obs",
            "Notepadplus", "Sumatra", "7zip", "Cpuz",
            "ClasicMixer", "Hwinfo", "Msiafterburner", "Qbittorrent"
        ) -contains $checkBox.Name.Replace("DblInstall", "")){ $checkBox.IsChecked = $true }else{ $checkBox.IsChecked = $false }

    }
    if ($wpf_ToggleGamingPreset.IsChecked){ Write-Host "Enabling Gaming Preset" -ForegroundColor Green} else { Write-Host "Disabling Gaming Preset" -ForegroundColor Red  }
}