function Invoke-ToggleDetailedBSoD{

    If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl")) {
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -PropertyType DWord -Value 0 -Force
    }
    else {
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -PropertyType DWord -Value 0 -Force
    }
    Toggle-RegistryValue -CheckBox $wpf_ToggleDetailedBSoD -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -TrueValue 1 -FalseValue 0 -EnableMessage "Enabling Detailed BSoD" -DisableMessage "Disabling Detailed BSoD"
}