function Invoke-ToggleBingSearchMenu{
    Toggle-RegistryValue -CheckBox $wpf_ToggleBingSearchMenu -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -TrueValue 1 -FalseValue 0 -EnableMessage "Enabled Bing Search" -DisableMessage "Disabling Bing Search"
}