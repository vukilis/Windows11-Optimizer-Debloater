function Get-CheckerTweaks{
    <#

    .SYNOPSIS
        This function checks if toggle tweaks are already check 
    #>

    $a = $wpf_ToggleBingSearchMenu.IsChecked = Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled'
    $b = $wpf_ToggleNumLock.IsChecked = Get-ToggleValue -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators'
    $c = $wpf_ToggleExt.IsChecked = (Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt') -eq 0
    $d = $wpf_ToggleMouseAcceleration.IsChecked = (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2')
    $getValue = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden'
    $e = $wpf_ToggleHiddenFiles.IsChecked = $(If ($getValue -eq 0) {$false} Else {$true})
    $f = $wpf_ToggleSearch.IsChecked = (Get-ToggleValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode') -eq 0
    $g = $wpf_TogglefIPv6.IsChecked = $(If ((Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "True" -And $(Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "False") {$true} Else {$false})

    return $a -and $b -and $c -and $d -and $e -and $f -and $g
}
Get-CheckerTweaks | out-null