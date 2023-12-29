function Invoke-ToggleNumLock{
    Toggle-RegistryValue -CheckBox $wpf_ToggleNumLock -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -TrueValue 2 -FalseValue 0 -EnableMessage "Enabling Numlock on startup" -DisableMessage "Disabling Numlock on startup"
}