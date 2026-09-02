Function Set-WinService {
    <#
    .SYNOPSIS
        Changes the startup type of the given service

    .PARAMETER Name
        The name of the service to modify

    .PARAMETER StartupType
        The startup type to set the service to

    .EXAMPLE
        Set-WinService -Name "HomeGroupListener" -StartupType "Manual"
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Automatic", "Manual", "Disabled")]
        [string]$StartupType
    )

    Write-Host "Setting Service $Name to $StartupType"

    # Check if the service exists
    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue

    if ($null -eq $service) {
        return
    }

    try {
        Write-Host "Setting Service $Name to $StartupType"
        $service | Set-Service -StartupType $StartupType -ErrorAction Stop
    }
    catch {
        Write-Warning "Unable to set service '$Name': $($_.Exception.Message)"
    }
}
