function Invoke-ToggleDarkMode {
    $themeRegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $EnableDarkMode = $wpf_ToggleDarkMode.IsChecked
    $appsTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme'
    $systemTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme'

    if ($appsTheme.AppsUseLightTheme -eq 1) {
        # Dark theme is currently active, switch to light theme
        Set-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme' -Value 0
        Set-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme' -Value 0
        #Write-Host "Switched to Dark Theme."
    } else {
        # Light theme is currently active, switch to dark theme
        Set-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme' -Value 1
        Set-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme' -Value 1
        #Write-Host "Switched to Light Theme."
    }
    Write-Host $(If ( $EnableDarkMode ) {"Enabling Dark Mode"} Else {"Disabling Dark Mode"})
}