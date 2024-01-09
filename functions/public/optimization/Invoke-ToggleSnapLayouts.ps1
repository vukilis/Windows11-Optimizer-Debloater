function Invoke-ToggleSnapLayouts{
    taskkill.exe /F /IM "explorer.exe"
    Toggle-RegistryValue -CheckBox $wpf_ToggleSnapLayouts -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'EnableSnapAssistFlyout' -TrueValue 0 -FalseValue 1 -EnableMessage "Disabling Snap Layouts" -DisableMessage "Enabled Snap Layouts"
    Start-Process "explorer.exe"
}