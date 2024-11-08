function Get-CheckerTweaks{
    <#

    .SYNOPSIS
        This function checks if toggle tweaks are already check 
    #>

    $a = $wpf_ToggleBingSearchMenu.IsChecked = Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled'
    $b = $wpf_ToggleNumLock.IsChecked = Get-ToggleValue -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators'
    $c = $wpf_ToggleExt.IsChecked = (Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt') -eq 0
    $d = $wpf_ToggleMouseAcceleration.IsChecked = (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2')
    
    $getE = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden'
    $e = $wpf_ToggleHiddenFiles.IsChecked = $(If ($getE -eq 0) {$false} Else {$true})
    
    $f = $wpf_ToggleSearch.IsChecked = (Get-ToggleValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode') -eq 0
    $g = $wpf_TogglefIPv6.IsChecked = $(If ((Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "True" -And $(Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "False") {$true} Else {$false})
    
    $getH = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'EnableSnapAssistFlyout'
    $h = $wpf_ToggleSnapLayouts.IsChecked = $(If ($getH -eq 0) {$true} Else {$false})
    
    $getI = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object -ExpandProperty "VerboseStatus" -ErrorAction SilentlyContinue
    if ($getI) { $i = $wpf_ToggleVerboseLogon.IsChecked = $(If ($getI -eq 0) {$false} Else {$true}) }
    
    $getJ = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
    if ($getJ) { $j = $wpf_ToggleCopilot.IsChecked = $(If ($getJ -eq 0) {$false} Else {$true}) }

    $getK = Get-ItemPropertyValue 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags'
    $k = $wpf_ToggleSticky.IsChecked = $(If ($getK -eq 58) {$true} Else {$false})

    $l = $wpf_ToggleEndTask.IsChecked = (Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings') -and ((Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Name 'TaskbarEndTask') -eq 1) -or 0
    
    return $a -and $b -and $c -and $d -and $e -and $f -and $g -and $h -and $i -and $j -and $k -and $l
}
Get-CheckerTweaks | Out-Null