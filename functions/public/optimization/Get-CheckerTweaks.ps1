function Get-CheckerTweaks {
    <#
    .SYNOPSIS
        This function checks if toggle tweaks are already set
    #>

    param ()

    $a = $wpf_ToggleBingSearchMenu.IsChecked = Get-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled'
    $b = $wpf_ToggleNumLock.IsChecked = (Get-RegistryValue -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators') -eq 2
    $c = $wpf_ToggleExt.IsChecked = (Get-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt') -eq 0
    $d = $wpf_ToggleMouseAcceleration.IsChecked = (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2')
    $e = $wpf_ToggleHiddenFiles.IsChecked = (((Get-RegistryValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden')))
    $f = $wpf_ToggleSearch.IsChecked = (Get-RegistryValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode') -eq 0
    $g = $wpf_TogglefIPv6.IsChecked = $(If ((Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "True" -And 
        $(Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "False") {$true} Else {$false})
    $h = $wpf_ToggleSnapLayouts.IsChecked = (((Get-RegistryValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'EnableSnapAssistFlyout') -eq 0))
    $i = $wpf_ToggleVerboseLogon.IsChecked = (((Get-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'VerboseStatus')))
    $j = $wpf_ToggleCopilot.IsChecked = (((Get-RegistryValue -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot')))
    $k = $wpf_ToggleSticky.IsChecked = (((Get-RegistryValue -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags') -eq 58))
    $l = $wpf_ToggleEndTask.IsChecked = (((Get-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Name 'TaskbarEndTask') -eq 1))
    $m = $wpf_ToggleCenterTaskbar.IsChecked = (((Get-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl') -eq 1))
    $n = $wpf_ToggleDetailedBSoD.IsChecked = (((Get-RegistryValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters') -eq 1))

    return $a -and $b -and $c -and $d -and $e -and $f -and $g -and $h -and $i -and $j -and $k -and $l -and $m -and $n
}

# Invoke and discard result (to only update UI)
Get-CheckerTweaks | Out-Null
