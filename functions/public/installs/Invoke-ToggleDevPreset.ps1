function Invoke-ToggleDevPreset {
    <#

    .SYNOPSIS
        Developer preset to help when installing apps   
    #>

    $IsChecked = $wpf_ToggleDevPreset.IsChecked
    $wpf_ToggleLitePreset.IsEnabled = !$IsChecked; $wpf_ToggleLitePreset.Style = $wpf_ToggleLitePreset.TryFindResource(('ToggleSwitchStyle' + ('Green', 'Disabled')[$IsChecked]))
    $wpf_ToggleGamingPreset.IsEnabled = !$IsChecked; $wpf_ToggleGamingPreset.Style = $wpf_ToggleGamingPreset.TryFindResource(('ToggleSwitchStyle' + ('Blue', 'Disabled')[$IsChecked]))

    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $checkBox = $psform.FindName($program.Id)
        $isChecked = $checkBox.IsChecked

        if ($checkBox.IsChecked -eq $false -and @(
            "Githubdesktop", "Nodemanager", "Java8", "Ohmyposh",
            "Python3", "Postman", "Visualstudio2022", "Code",
            "Dotnet3", "Dotnet5", "Dotnet6", "Dotnet7",
            "Powershell", "vc2015_64", "vc2015_32", "Terminal",
            "Thorium", "Discord", "Slack", "Teams", "Zoom",
            "Steam", "Greenshot", "Imageglass", "Klite", "Vlc",
            "Notepadplus", "7zip", "Cpuz", "ClasicMixer", "Hwinfo",
            "Jdownloader", "Msiafterburner", "OVirtualBox", "Qbittorrent",
            "Ttaskbar", "Winrar", "Sumatra"
        ) -contains $checkBox.Name.Replace("DblInstall", "")){ $checkBox.IsChecked = $true }else{ $checkBox.IsChecked = $false }

    }
    if ($wpf_ToggleDevPreset.IsChecked){ Write-Host "Enabling Dev Preset" -ForegroundColor Green} else { Write-Host "Disabling Dev Preset" -ForegroundColor Red  }
}