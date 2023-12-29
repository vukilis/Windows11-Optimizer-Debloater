function Get-ToggleValue {
    <#

    .SYNOPSIS
        Handler function to get registry information for toggle tweakes
        Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled'
    #>
    param (
        [string]$Path,
        [string]$Name
    )

    return (Get-ItemProperty -Path $Path).$Name -ne 0
}