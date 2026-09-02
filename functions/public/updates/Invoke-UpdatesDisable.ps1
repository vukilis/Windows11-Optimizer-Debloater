function Invoke-UpdatesDisable {
    <#

    .SYNOPSIS
        Disable Windows Update

    .NOTES
        Disabling Windows Update is not recommended.
        Security updates will not be installed until Windows Update is restored.

    #>

    Write-Host "Configuring Windows Update registry settings..." -ForegroundColor Yellow

    $windowsUpdatePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $automaticUpdatePolicyPath = Join-Path $windowsUpdatePolicyPath "AU"
    $deliveryOptimizationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"

    # Windows Update policy
    If (!(Test-Path $automaticUpdatePolicyPath)) {
        New-Item -Path $automaticUpdatePolicyPath -Force | Out-Null
    }

    Set-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "NoAutoUpdate" `
        -Type DWord `
        -Value 1

    Set-ItemProperty `
        -Path $automaticUpdatePolicyPath `
        -Name "AUOptions" `
        -Type DWord `
        -Value 1

    # Disable Delivery Optimization downloads
    If (!(Test-Path $deliveryOptimizationPath)) {
        New-Item -Path $deliveryOptimizationPath -Force | Out-Null
    }

    Set-ItemProperty `
        -Path $deliveryOptimizationPath `
        -Name "DODownloadMode" `
        -Type DWord `
        -Value 0

    # Stop and disable Windows Update services
    $services = @(
        "BITS"
        "wuauserv"
        "UsoSvc"
    )

    foreach ($service in $services) {
        Write-Host "Stopping and disabling $service service..."

        Stop-Service `
            -Name $service `
            -Force `
            -ErrorAction SilentlyContinue

        Set-Service `
            -Name $service `
            -StartupType Disabled `
            -ErrorAction SilentlyContinue
    }

    # Clear downloaded Windows Update files
    Write-Host "Clearing downloaded Windows Update files..." -ForegroundColor Yellow

    Remove-Item `
        -Path "C:\Windows\SoftwareDistribution\*" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

    # Disable Windows Update scheduled tasks
    Write-Host "Disabling Windows Update scheduled tasks..." -ForegroundColor Yellow

    $Tasks = @(
        '\Microsoft\Windows\InstallService\*'
        '\Microsoft\Windows\UpdateOrchestrator\*'
        '\Microsoft\Windows\UpdateAssistant\*'
        '\Microsoft\Windows\WaaSMedic\*'
        '\Microsoft\Windows\WindowsUpdate\*'
        '\Microsoft\WindowsUpdate\*'
    )

    foreach ($Task in $Tasks) {
        Get-ScheduledTask `
            -TaskPath $Task `
            -ErrorAction SilentlyContinue |
            Disable-ScheduledTask `
                -ErrorAction SilentlyContinue
    }

    Art -artN "
==================================
------ Updates ARE DISABLED ------
==================================
" -ch DarkRed

    Write-Host "Note: You must restart your system for all changes to take effect." -ForegroundColor Yellow

    Invoke-MessageBox -msg "updateDisabled"
}