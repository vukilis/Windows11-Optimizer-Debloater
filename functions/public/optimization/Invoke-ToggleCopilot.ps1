function Invoke-ToggleCopilot{
    If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -PropertyType DWord -Value 0 -Force
    }
    else {
        New-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -PropertyType DWord -Value 0 -Force
    }
    taskkill.exe /F /IM "explorer.exe"
    Toggle-RegistryValue -CheckBox $wpf_ToggleCopilot -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -TrueValue 1 -FalseValue 0 -EnableMessage "Disabling Copilot" -DisableMessage "Enabling Copilot"
    Start-Process "explorer.exe"
}