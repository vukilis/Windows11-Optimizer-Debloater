
function Invoke-TogglePasswordReveal{    

    If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\CredUI")) {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\CredUI" -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\CredUI' -Name 'DisablePasswordReveal' -PropertyType DWord -Value 0 -Force
    }
    else {
        New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\CredUI' -Name 'DisablePasswordReveal' -PropertyType DWord -Value 0 -Force
    }

    Toggle-RegistryValue -CheckBox $wpf_TogglePasswordReveal -Path 'HKLM:\Software\Policies\Microsoft\Windows\CredUI' -Name 'DisablePasswordReveal' -TrueValue 0 -FalseValue 1 -EnableMessage "Enabling Password Reveal" -DisableMessage "Disabling Password Reveal"
}