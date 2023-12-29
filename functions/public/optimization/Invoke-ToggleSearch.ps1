function Invoke-ToggleSearch{
    Toggle-RegistryValue -CheckBox $wpf_ToggleSearch -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode' -TrueValue 0 -FalseValue 2 -EnableMessage "Hiding search box" -DisableMessage "Showing search box"
}