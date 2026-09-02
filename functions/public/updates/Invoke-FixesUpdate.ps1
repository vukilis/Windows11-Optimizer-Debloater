function Invoke-FixesUpdate {
    <#

    .SYNOPSIS
        Repairs Windows Update by resetting services, cache,
        DLL registrations, BITS jobs, networking, and Windows Update policies.

    #>

    Write-Host "1. Stopping Windows Update Services..." -ForegroundColor Yellow

    $services = @(
        "BITS"
        "wuauserv"
        "appidsvc"
        "cryptsvc"
    )

    foreach ($service in $services) {
        Write-Host "Stopping $service..."
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    }


    Write-Host "2. Removing QMGR Data files..." -ForegroundColor Yellow

    Remove-Item `
        "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" `
        -Force `
        -ErrorAction SilentlyContinue


    Write-Host "3. Renaming Windows Update folders..." -ForegroundColor Yellow

    # SoftwareDistribution
    If (Test-Path "$env:systemroot\SoftwareDistribution") {
        Rename-Item `
            "$env:systemroot\SoftwareDistribution" `
            "SoftwareDistribution.bak" `
            -ErrorAction SilentlyContinue
    }

    # Catroot2
    If (Test-Path "$env:systemroot\System32\Catroot2") {
        Rename-Item `
            "$env:systemroot\System32\Catroot2" `
            "Catroot2.bak" `
            -ErrorAction SilentlyContinue
    }


    Write-Host "4. Removing old Windows Update log..." -ForegroundColor Yellow

    Remove-Item `
        "$env:systemroot\WindowsUpdate.log" `
        -Force `
        -ErrorAction SilentlyContinue


    Write-Host "5. Resetting Windows Update service security..." -ForegroundColor Yellow

    $serviceSecurityDescriptor = "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

    Start-Process `
        -NoNewWindow `
        -FilePath "sc.exe" `
        -ArgumentList "sdset", "bits", $serviceSecurityDescriptor `
        -Wait

    Start-Process `
        -NoNewWindow `
        -FilePath "sc.exe" `
        -ArgumentList "sdset", "wuauserv", $serviceSecurityDescriptor `
        -Wait


    Write-Host "6. Registering Windows Update DLLs..." -ForegroundColor Yellow

    $oldLocation = Get-Location

    Set-Location "$env:systemroot\System32"

    $DLLs = @(
        "atl.dll"
        "urlmon.dll"
        "mshtml.dll"
        "shdocvw.dll"
        "browseui.dll"
        "jscript.dll"
        "vbscript.dll"
        "scrrun.dll"
        "msxml.dll"
        "msxml3.dll"
        "msxml6.dll"
        "actxprxy.dll"
        "softpub.dll"
        "wintrust.dll"
        "dssenh.dll"
        "rsaenh.dll"
        "gpkcsp.dll"
        "sccbase.dll"
        "slbcsp.dll"
        "cryptdlg.dll"
        "oleaut32.dll"
        "ole32.dll"
        "shell32.dll"
        "initpki.dll"
        "wuapi.dll"
        "wuaueng.dll"
        "wuaueng1.dll"
        "wucltui.dll"
        "wups.dll"
        "wups2.dll"
        "wuweb.dll"
        "qmgr.dll"
        "qmgrprxy.dll"
        "wucltux.dll"
        "muweb.dll"
        "wuwebv.dll"
    )

    foreach ($dll in $DLLs) {
        If (Test-Path $dll) {
            Start-Process `
                -NoNewWindow `
                -FilePath "regsvr32.exe" `
                -ArgumentList "/s", $dll `
                -Wait
        }
    }

    Set-Location $oldLocation


    Write-Host "7. Removing WSUS client settings..." -ForegroundColor Yellow

    $windowsUpdatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate"

    If (Test-Path $windowsUpdatePath) {
        Remove-ItemProperty `
            -Path $windowsUpdatePath `
            -Name "AccountDomainSid" `
            -ErrorAction SilentlyContinue

        Remove-ItemProperty `
            -Path $windowsUpdatePath `
            -Name "PingID" `
            -ErrorAction SilentlyContinue

        Remove-ItemProperty `
            -Path $windowsUpdatePath `
            -Name "SusClientId" `
            -ErrorAction SilentlyContinue
    }


    Write-Host "8. Removing Windows Update policy settings..." -ForegroundColor Yellow

    $windowsUpdatePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $automaticUpdatePolicyPath = Join-Path $windowsUpdatePolicyPath "AU"

    $registryValues = @(
        @{
            Path = $automaticUpdatePolicyPath
            Names = @(
                "NoAutoUpdate"
                "AUOptions"
                "NoAutoRebootWithLoggedOnUsers"
                "AUPowerManagement"
            )
        }
        @{
            Path = $windowsUpdatePolicyPath
            Names = @(
                "ExcludeWUDriversInQualityUpdate"
                "DeferFeatureUpdates"
                "DeferFeatureUpdatesPeriodInDays"
                "DeferQualityUpdates"
                "DeferQualityUpdatesPeriodInDays"
            )
        }
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
            Names = @(
                "BranchReadinessLevel"
                "DeferFeatureUpdatesPeriodInDays"
                "DeferQualityUpdatesPeriodInDays"
                "PauseUpdatesStartTime"
                "PauseUpdatesExpiryTime"
                "PauseFeatureUpdatesStartTime"
                "PauseFeatureUpdatesEndTime"
                "PauseQualityUpdatesStartTime"
                "PauseQualityUpdatesEndTime"
                "PauseUpdatesExpiryTime"
            )
        }
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata"
            Names = @(
                "PreventDeviceMetadataFromNetwork"
            )
        }
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching"
            Names = @(
                "DontPromptForWindowsUpdate"
                "DontSearchWindowsUpdate"
                "DriverUpdateWizardWuSearchEnabled"
            )
        }
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
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


    Write-Host "9. Resetting WinSock and network configuration..." -ForegroundColor Yellow

    Start-Process `
        -NoNewWindow `
        -FilePath "netsh.exe" `
        -ArgumentList "winsock", "reset" `
        -Wait

    Start-Process `
        -NoNewWindow `
        -FilePath "netsh.exe" `
        -ArgumentList "winhttp", "reset", "proxy" `
        -Wait

    Start-Process `
        -NoNewWindow `
        -FilePath "netsh.exe" `
        -ArgumentList "int", "ip", "reset" `
        -Wait


    Write-Host "10. Removing all BITS jobs..." -ForegroundColor Yellow

    Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue |
        Remove-BitsTransfer -ErrorAction SilentlyContinue


    Write-Host "11. Restoring Windows Update Services..." -ForegroundColor Yellow

    # BITS
    Set-Service `
        -Name "BITS" `
        -StartupType Manual `
        -ErrorAction SilentlyContinue

    Start-Service `
        -Name "BITS" `
        -ErrorAction SilentlyContinue

    # Windows Update
    Set-Service `
        -Name "wuauserv" `
        -StartupType Manual `
        -ErrorAction SilentlyContinue

    Start-Service `
        -Name "wuauserv" `
        -ErrorAction SilentlyContinue

    # AppIDSvc is protected, so configure it through the registry
    Set-ItemProperty `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AppIDSvc" `
        -Name "Start" `
        -Type DWord `
        -Value 3 `
        -ErrorAction SilentlyContinue

    Start-Service `
        -Name "AppIDSvc" `
        -ErrorAction SilentlyContinue

    # Cryptographic Services
    Set-Service `
        -Name "CryptSvc" `
        -StartupType Automatic `
        -ErrorAction SilentlyContinue

    Start-Service `
        -Name "CryptSvc" `
        -ErrorAction SilentlyContinue


    Write-Host "12. Enabling Windows Update scheduled tasks..." -ForegroundColor Yellow

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
            Enable-ScheduledTask `
                -ErrorAction SilentlyContinue
    }


    Write-Host "13. Forcing Windows Update discovery..." -ForegroundColor Yellow

    try {
        (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
    }
    catch {
        Write-Warning "Failed to create Windows Update COM object: $_"
    }

    Start-Process `
        -NoNewWindow `
        -FilePath "wuauclt.exe" `
        -ArgumentList "/resetauthorization", "/detectnow" `
        -Wait


    Write-Host ""
    Write-Host "Process complete. Please reboot your computer." -ForegroundColor Yellow

    Art -artN "
===============================================
-- Reset All Windows Update Settings to Stock -
===============================================
" -ch DarkGreen

    Invoke-MessageBox -msg "updateFix"
}