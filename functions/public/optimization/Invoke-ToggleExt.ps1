function Invoke-ToggleExt{
    Toggle-RegistryValue -CheckBox $wpf_ToggleExt -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -TrueValue 0 -FalseValue 1 -EnableMessage "Showing file extentions" -DisableMessage "Hiding file extensions"
}