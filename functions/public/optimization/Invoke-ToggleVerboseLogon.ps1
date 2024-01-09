function Invoke-ToggleVerboseLogon{

    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'VerboseStatus' -PropertyType DWord -Value 0 -Force
    Toggle-RegistryValue -CheckBox $wpf_ToggleVerboseLogon -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'VerboseStatus' -TrueValue 1 -FalseValue 0 -EnableMessage "Enabling Verbose Logon" -DisableMessage "Disabling Verbose Logon"
}