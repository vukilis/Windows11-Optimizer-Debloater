function Invoke-UpdatesDefault {
    <#

    .SYNOPSIS
        Resets Windows Update settings to default

    #>

    Write-Host "Removing Windows Update settings..." -ForegroundColor Green

    $windowsUpdatePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $automaticUpdatePolicyPath = Join-Path $windowsUpdatePolicyPath "AU"
    $deliveryOptimizationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"

    # Remove Windows Update policy settings
    $registryValues = @(
        @{
            Path = $automaticUpdatePolicyPath
            Names = @(
                "NoAutoUpdate",
                "AUOptions",
                "NoAutoRebootWithLoggedOnUsers",
                "AUPowerManagement"
            )
        },
        @{
            Path = $windowsUpdatePolicyPath
            Names = @(
                "ExcludeWUDriversInQualityUpdate",
                "DeferFeatureUpdates",
                "DeferFeatureUpdatesPeriodInDays",
                "DeferQualityUpdates",
                "DeferQualityUpdatesPeriodInDays"
            )
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
            Names = @(
                "BranchReadinessLevel",
                "DeferFeatureUpdatesPeriodInDays",
                "DeferQualityUpdatesPeriodInDays"
            )
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata"
            Names = @(
                "PreventDeviceMetadataFromNetwork"
            )
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching"
            Names = @(
                "DontPromptForWindowsUpdate",
                "DontSearchWindowsUpdate",
                "DriverUpdateWizardWuSearchEnabled"
            )
        },
        @{
            Path = $deliveryOptimizationPath
            Names = @(
                "DODownloadMode"
            )
        }
    )

    foreach ($registryEntry in $registryValues) {
        foreach ($valueName in $registryEntry.Names) {
            Remove-ItemProperty `
                -Path $registryEntry.Path `
                -Name $valueName `
                -ErrorAction SilentlyContinue
        }
    }

    # Restore legacy Windows Update settings page visibility
    $explorerPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"

    $settingsPageVisibility = (
        Get-ItemProperty `
            -Path $explorerPolicyPath `
            -Name "SettingsPageVisibility" `
            -ErrorAction SilentlyContinue
    ).SettingsPageVisibility

    If ($settingsPageVisibility -eq "hide:windowsupdate") {
        Write-Host "Removing Windows Update settings page restriction..."
        Remove-ItemProperty `
            -Path $explorerPolicyPath `
            -Name "SettingsPageVisibility" `
            -ErrorAction SilentlyContinue
    }

    # Restore Windows Update services
    Write-Host "Restoring Windows Update services..." -ForegroundColor Green

    Write-Host "Restoring BITS to Manual."
    Set-Service `
        -Name "BITS" `
        -StartupType Manual `
        -ErrorAction SilentlyContinue

    Write-Host "Restoring wuauserv to Manual."
    Set-Service `
        -Name "wuauserv" `
        -StartupType Manual `
        -ErrorAction SilentlyContinue

    Write-Host "Restoring UsoSvc to Automatic."
    Set-Service `
        -Name "UsoSvc" `
        -StartupType Automatic `
        -ErrorAction SilentlyContinue

    Start-Service `
        -Name "UsoSvc" `
        -ErrorAction SilentlyContinue

    # Enable Windows Update scheduled tasks
    Write-Host "Enabling Windows Update scheduled tasks..." -ForegroundColor Green

    $Tasks = @(
        '\Microsoft\Windows\InstallService\*',
        '\Microsoft\Windows\UpdateOrchestrator\*',
        '\Microsoft\Windows\UpdateAssistant\*',
        '\Microsoft\Windows\WaaSMedic\*',
        '\Microsoft\Windows\WindowsUpdate\*',
        '\Microsoft\WindowsUpdate\*'
    )

    foreach ($Task in $Tasks) {
        Get-ScheduledTask `
            -TaskPath $Task `
            -ErrorAction SilentlyContinue |
            Enable-ScheduledTask `
                -ErrorAction SilentlyContinue
    }

    Art -artN "
==================================
----- Updates Set to Default -----
==================================
" -ch Cyan

    Write-Host "Note: You must restart your system for all changes to take effect." -ForegroundColor Yellow

    Invoke-MessageBox -msg "updateDefault"
}