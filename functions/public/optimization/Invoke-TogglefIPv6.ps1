function Invoke-TogglefIPv6{    
    $EnableMode = $wpf_TogglefIPv6.IsChecked
    $ToggleValue = $(If ( $EnableMode ) {0} Else {1})
    If ($ToggleValue -ne 1){
        Enable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
    }
    if ($ToggleValue -ne 0){
        Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
    }
    Write-Host $(If ( $EnableMode ) {"Enabling IPv6"} Else {"Disabling IPv6"})
}