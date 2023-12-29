function Set-RegistryValue {
    <#

    .SYNOPSIS
        Handler function to set registry information
        Set-RegistryValue -Path $Path -Name $Name -Value $TrueValue
    #>

    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
}