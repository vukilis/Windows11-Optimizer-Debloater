function Invoke-ToggleLitePreset {
    <#

    .SYNOPSIS
        Minimal preset to help when installing apps   
    #>

    $IsChecked = $wpf_ToggleLitePreset.IsChecked
    $wpf_ToggleDevPreset.IsEnabled = !$IsChecked; $wpf_ToggleDevPreset.Style = $wpf_ToggleDevPreset.TryFindResource(('ToggleSwitchStyle' + ('Purple', 'Disabled')[$IsChecked]))
    $wpf_ToggleGamingPreset.IsEnabled = !$IsChecked; $wpf_ToggleGamingPreset.Style = $wpf_ToggleGamingPreset.TryFindResource(('ToggleSwitchStyle' + ('Blue', 'Disabled')[$IsChecked]))

    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $checkBox = $psform.FindName($program.Id)
        $isChecked = $checkBox.IsChecked

        if ($checkBox.IsChecked -eq $false -and @(
            "Git", "Java8", "Ohmyposh", "Code", "Powershell", 
            "vc2015_64", "vc2015_32", "Terminal", "Thorium", 
            "Discord", "Steam", "Greenshot", "Imageglass", "Klite", 
            "Spotify", "Vlc", "Notepadplus", "Sumatra", "7zip", "Cpuz", 
            "ClasicMixer", "Hwinfo", "Jdownloader", "Msiafterburner", 
            "Qbittorrent", "Ttaskbar"
        ) -contains $checkBox.Name.Replace("DblInstall", "")){ $checkBox.IsChecked = $true }else{ $checkBox.IsChecked = $false }
    }

    if ($wpf_ToggleLitePreset.IsChecked){ Write-Host "Enabling Lite Preset" -ForegroundColor Green} else { Write-Host "Disabling Lite Preset" -ForegroundColor Red  }
}