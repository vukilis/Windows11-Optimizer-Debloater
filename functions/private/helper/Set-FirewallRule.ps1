function Set-FirewallRule {
    <#
    .SYNOPSIS
        Enables or disables a firewall rule group for a given profile.

    .PARAMETER Group
        The firewall rule group (e.g. "Network Discovery").

    .PARAMETER Profile
        The firewall profile (Domain, Private, Public, Any).

    .PARAMETER Action
        Enable or Disable.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Domain","Private","Public","Any")]
        [string]$Profile,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Enable","Disable")]
        [string]$Action
    )

    try {
        Write-Host "[$Action] firewall group '$Group' on profile '$Profile'" -ForegroundColor Cyan

        # Get matching rules first
        $rules = if ($Profile -eq "Any") {
            Get-NetFirewallRule -DisplayGroup $Group -ErrorAction Stop
        } else {
            Get-NetFirewallRule -DisplayGroup $Group -ErrorAction Stop |
                Where-Object { $_.Profile -match $Profile }
        }

        if ($rules.Count -eq 0) {
            Write-Warning "No firewall rules found for group '$Group' and profile '$Profile'"
            return
        }

        if ($Action -eq "Enable") {
            $rules | Enable-NetFirewallRule
        }
        elseif ($Action -eq "Disable") {
            $rules | Disable-NetFirewallRule
        }
    }
    catch {
        Write-Warning "Failed to update firewall group '$Group' on profile '$Profile': $_"
    }
}
