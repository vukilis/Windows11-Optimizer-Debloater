function Invoke-ToggleEndTask{

    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Force | Out-Null
    }
    Toggle-RegistryValue -CheckBox $wpf_ToggleEndTask -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Name 'TaskbarEndTask' -TrueValue 1 -FalseValue 0 -EnableMessage "Showing End Button" -DisableMessage "Hiding End Button"
}