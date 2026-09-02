function Invoke-UpdatesSecurity {
    <#

    .SYNOPSIS
        Set Windows Update to security

    .DESCRIPTION
        1. Disables driver offering through Windows Update
        2. Restores Windows Update services and scheduled tasks
        3. Prevents automatic restarts while a user is signed in
        4. Defers feature updates for 365 days
        5. Defers quality updates for 4 days

    #>

    $windowsUpdatePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $automaticUpdatePolicyPath = Join-Path $windowsUpdatePolicyPath "AU"

    Write-Host "Restoring Windows Update availability..."

    # Restore Windows Update policy values that may have been disabled
    Remove-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "NoAutoUpdate" `
        -ErrorAction SilentlyContinue

    Remove-ItemProperty `
        -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" `
        -Name "DODownloadMode" `
        -ErrorAction SilentlyContinue

    # Restore Windows Update services
    Set-Service -Name BITS -StartupType Manual
    Set-Service -Name wuauserv -StartupType Manual
    Set-Service -Name UsoSvc -StartupType Automatic

    Start-Service -Name UsoSvc -ErrorAction SilentlyContinue

    # Enable Windows Update scheduled tasks
    $Tasks = @(
        '\Microsoft\Windows\InstallService\*',
        '\Microsoft\Windows\UpdateOrchestrator\*',
        '\Microsoft\Windows\UpdateAssistant\*',
        '\Microsoft\Windows\WaaSMedic\*',
        '\Microsoft\Windows\WindowsUpdate\*',
        '\Microsoft\WindowsUpdate\*'
    )

    foreach ($Task in $Tasks) {
        Get-ScheduledTask -TaskPath $Task -ErrorAction SilentlyContinue |
            Enable-ScheduledTask -ErrorAction SilentlyContinue
    }

    Write-Host "Disabling driver offering through Windows Update..."

    # Device Metadata
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata")) {
        New-Item `
            -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" `
            -Force |
            Out-Null
    }

    Set-ItemProperty `
        -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" `
        -Name "PreventDeviceMetadataFromNetwork" `
        -Type DWord `
        -Value 1

    # Driver Searching
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching")) {
        New-Item `
            -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" `
            -Force |
            Out-Null
    }

    Set-ItemProperty `
        -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" `
        -Name "DontPromptForWindowsUpdate" `
        -Type DWord `
        -Value 1

    Set-ItemProperty `
        -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" `
        -Name "DontSearchWindowsUpdate" `
        -Type DWord `
        -Value 1

    Set-ItemProperty `
        -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" `
        -Name "DriverUpdateWizardWuSearchEnabled" `
        -Type DWord `
        -Value 0

    # Windows Update driver exclusion
    If (!(Test-Path $windowsUpdatePolicyPath)) {
        New-Item -Path $windowsUpdatePolicyPath -Force | Out-Null
    }

    Set-ItemProperty `
        -Path $windowsUpdatePolicyPath `
        -Name "ExcludeWUDriversInQualityUpdate" `
        -Type DWord `
        -Value 1

    Write-Host "Deferring feature updates by 365 days and quality updates by 4 days..."

    # Feature update deferral
    Set-ItemProperty `
        -Path $windowsUpdatePolicyPath `
        -Name "DeferFeatureUpdates" `
        -Type DWord `
        -Value 1

    Set-ItemProperty `
        -Path $windowsUpdatePolicyPath `
        -Name "DeferFeatureUpdatesPeriodInDays" `
        -Type DWord `
        -Value 365

    # Quality update deferral
    Set-ItemProperty `
        -Path $windowsUpdatePolicyPath `
        -Name "DeferQualityUpdates" `
        -Type DWord `
        -Value 1

    Set-ItemProperty `
        -Path $windowsUpdatePolicyPath `
        -Name "DeferQualityUpdatesPeriodInDays" `
        -Type DWord `
        -Value 4

    # Remove legacy Windows Update UX settings
    $legacySettingsPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"

    foreach ($legacyValue in @(
        "BranchReadinessLevel",
        "DeferFeatureUpdatesPeriodInDays",
        "DeferQualityUpdatesPeriodInDays"
    )) {
        Remove-ItemProperty `
            -Path $legacySettingsPath `
            -Name $legacyValue `
            -ErrorAction SilentlyContinue
    }

    Write-Host "Disabling Windows Update automatic restart..."

    # Create AU policy path
    If (!(Test-Path $automaticUpdatePolicyPath)) {
        New-Item `
            -Path $automaticUpdatePolicyPath `
            -Force |
            Out-Null
    }

    # Scheduled automatic updates
    Set-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "AUOptions" `
        -Type DWord `
        -Value 4

    # Prevent automatic restart while a user is logged on
    Set-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "NoAutoRebootWithLoggedOnUsers" `
        -Type DWord `
        -Value 1

    # Do not use automatic restart/power management
    Set-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "AUPowerManagement" `
        -Type DWord `
        -Value 0

    Art -artN "
==================================
--- Updates Set to Recommended ---
==================================
" -ch Cyan

    Invoke-MessageBox -msg "updateSecurity"
}