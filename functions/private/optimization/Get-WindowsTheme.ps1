function Get-WindowsTheme {
    $themeRegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'

    $appsTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme'
    $systemTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme'

    if ($appsTheme.AppsUseLightTheme -eq 1) {
        return $false
    } else {
        return $true
    }
}
$wpf_ToggleDarkMode.IsChecked = Get-WindowsTheme