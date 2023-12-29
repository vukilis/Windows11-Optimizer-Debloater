function Invoke-ToggleMouseAcceleration{    
    $EnableMode = $wpf_ToggleMouseAcceleration.IsChecked
    $ToggleValue = $(If ( $EnableMode ) {0} Else {1})
    If ($ToggleValue -ne 1){
        $Path = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $Path -Name MouseSpeed -Value 1
        Set-ItemProperty -Path $Path -Name MouseThreshold1 -Value 6
        Set-ItemProperty -Path $Path -Name MouseThreshold2 -Value 10
    }
    if ($ToggleValue -ne 0){
        $Path = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $Path -Name MouseSpeed -Value 0
        Set-ItemProperty -Path $Path -Name MouseThreshold1 -Value 0
        Set-ItemProperty -Path $Path -Name MouseThreshold2 -Value 0
    }
    Write-Host $(If ( $EnableMode ) {"Enabling Mouse Acceleration"} Else {"Disabling Mouse Acceleration"})
}