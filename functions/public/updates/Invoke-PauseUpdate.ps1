function Invoke-PauseUpdate {
    <#

    .SYNOPSIS
        Pause Windows Update for up to 35 days or 5 weeks.

    #>

    Write-Host "Pausing Windows Update for 5 weeks..." -ForegroundColor Green

    $windowsUpdateUXPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    $automaticUpdatePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

    # Make sure the required registry paths exist
    If (!(Test-Path $windowsUpdateUXPath)) {
        New-Item -Path $windowsUpdateUXPath -Force | Out-Null
    }

    If (!(Test-Path $automaticUpdatePolicyPath)) {
        New-Item -Path $automaticUpdatePolicyPath -Force | Out-Null
    }

    # Calculate pause start and expiry dates
    $pauseStart = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $pauseEnd = (Get-Date).AddDays(35).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    # Set Windows Update pause dates
    Set-ItemProperty `
        -Path $windowsUpdateUXPath `
        -Name "PauseUpdatesStartTime" `
        -Value $pauseStart

    Set-ItemProperty `
        -Path $windowsUpdateUXPath `
        -Name "PauseUpdatesExpiryTime" `
        -Value $pauseEnd

    Set-ItemProperty `
        -Path $windowsUpdateUXPath `
        -Name "PauseFeatureUpdatesStartTime" `
        -Value $pauseStart

    Set-ItemProperty `
        -Path $windowsUpdateUXPath `
        -Name "PauseFeatureUpdatesEndTime" `
        -Value $pauseEnd

    Set-ItemProperty `
        -Path $windowsUpdateUXPath `
        -Name "PauseQualityUpdatesStartTime" `
        -Value $pauseStart

    Set-ItemProperty `
        -Path $windowsUpdateUXPath `
        -Name "PauseQualityUpdatesEndTime" `
        -Value $pauseEnd

    # Disable automatic updates while paused
    Set-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "NoAutoUpdate" `
        -Type DWord `
        -Value 1

    # Date displayed to the user
    $pauseDateOnly = (Get-Date).AddDays(35).ToString("yyyy-MM-dd")

    Art -artN "
======================================
-- Updates paused until $pauseDateOnly --
======================================
" -ch DarkGreen

    Invoke-MessageBox -msg "updatePause"
}