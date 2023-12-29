function Toggle-RegistryValue {
    <#

    .SYNOPSIS
        Handler function to get registry information
        Toggle-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled'
    #>

    param (
        [System.Windows.Controls.CheckBox]$CheckBox,
        [string]$Path,
        [string]$Name,
        [int]$TrueValue,
        [int]$FalseValue,
        [string]$EnableMessage,
        [string]$DisableMessage
    )

    $EnableMode = $CheckBox.IsChecked
    $ToggleValue = $(If ( $EnableMode ) {0} Else {1})

    If ($ToggleValue -ne 1){
        Set-RegistryValue -Path $Path -Name $Name -Value $TrueValue
        Write-Host $EnableMessage
    }
    if ($ToggleValue -ne 0){
        Set-RegistryValue -Path $Path -Name $Name -Value $FalseValue
        Write-Host $DisableMessage
    }
}