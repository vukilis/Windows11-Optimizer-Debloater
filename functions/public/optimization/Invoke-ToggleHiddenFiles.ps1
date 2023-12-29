function Invoke-ToggleHiddenFiles{
    Toggle-RegistryValue -CheckBox $wpf_ToggleHiddenFiles -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -TrueValue 1 -FalseValue 0 -EnableMessage "Showing hidden files" -DisableMessage "Hide hidden files"
}