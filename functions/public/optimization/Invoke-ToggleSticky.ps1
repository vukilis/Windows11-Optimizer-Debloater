function Invoke-ToggleSticky{
    Toggle-RegistryValue -CheckBox $wpf_ToggleSticky -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -TrueValue 58 -FalseValue 510 -EnableMessage "Disabling Sticky Keys" -DisableMessage "Enabling Sticky Keys"
}