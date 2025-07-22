function Invoke-ToggleCenterTaskbar{

    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAl")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAl" -Force | Out-Null
    }
    Toggle-RegistryValue -CheckBox $wpf_ToggleCenterTaskbar -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -TrueValue 1 -FalseValue 0 -EnableMessage "Taskbar Alignment to Center" -DisableMessage "Taskbar Alignment to Left"
}