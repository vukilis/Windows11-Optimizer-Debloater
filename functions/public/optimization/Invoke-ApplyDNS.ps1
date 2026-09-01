Function Invoke-ApplyDNS {
    <#

    .SYNOPSIS
        Applies DNS settings based on the selected provider in the UI.

    #>
    param(
        [string]$Provider
    )

    $dnsMap = @{
        "Default"                = @{ Primary = "DHCP"; Secondary = $null }
        "DHCP"                   = @{ Primary = "DHCP"; Secondary = $null }
        "Google"                 = @{ Primary = "8.8.8.8"; Secondary = "8.8.4.4" }
        "Cloudflare"             = @{ Primary = "1.1.1.1"; Secondary = "1.0.0.1" }
        "Cloudflare_Malware"     = @{ Primary = "1.1.1.2"; Secondary = "1.0.0.2" }
        "Cloudflare_Malware_Adult" = @{ Primary = "1.1.1.3"; Secondary = "1.0.0.3" }
        "Open_DNS"               = @{ Primary = "208.67.222.222"; Secondary = "208.67.220.220" }
        "Quad9"                  = @{ Primary = "9.9.9.9"; Secondary = "149.112.112.112" }
        "AdGuard_Ads_Trackers"               = @{ Primary = "94.140.14.14"; Secondary = "94.140.15.15" }
        "AdGuard_Ads_Trackers_Malware_Adult" = @{ Primary = "94.140.14.18"; Secondary = "94.140.15.18" }
        "Mulvad"                 = @{ Primary = "194.242.2.2"; Secondary = "5.2.78.30" }
        "Mulvad_Ads_Trackers"                = @{ Primary = "194.242.2.3"; Secondary = "5.2.79.30" }
        "Mulvad_Ads_Trackers_Malware"        = @{ Primary = "194.242.2.4"; Secondary = "5.2.80.30" }
        "Mulvad_Ads_Trackers_Malware_Social" = @{ Primary = "194.242.2.5"; Secondary = "5.2.81.30" }
        "Mulvad_Ads_Trackers_Malware_Adult_Gambling" = @{ Primary = "194.242.2.6"; Secondary = "5.2.82.30" }
        "Mulvad_Ads_Trackers_Malware_Adult_Gambling_Social" = @{ Primary = "194.242.2.9"; Secondary = "5.2.83.30" }
    }

    if (-not $dnsMap.ContainsKey($Provider)) {
        Write-Warning "Unknown DNS provider: $Provider"
        return
    }

    $dns = $dnsMap[$Provider]
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

    foreach ($adapter in $adapters) {
        Write-Host "Setting DNS on $($adapter.Name) to $Provider" -ForegroundColor Yellow
        if ($dns.Primary -eq "DHCP") {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses
        } else {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @($dns.Primary, $dns.Secondary)
        }
    }

    Write-Host "DNS settings applied successfully." -ForegroundColor Green
    Invoke-MessageBox "tweak"
}
