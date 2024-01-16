function Invoke-optimizationButton{
    <#

    .SYNOPSIS
        This function run selected tweaks
        Unselect tweaks after tweaking
    #>

    # Invoke restore point
    If ( $wpf_DblSystemRestore.IsChecked -eq $true ) {
        Set-RestorePoint
    }
    # Essential Tweaks
    If ( $wpf_DblTelemetry.IsChecked -eq $true ) {
        Write-Host "Disabling Telemetry..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
        Write-Host "Disabling Application suggestions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
        Write-Host "Disabling Feedback..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Disabling Tailored Experiences..."
        If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
        Write-Host "Disabling Advertising ID..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
        Write-Host "Disabling Error reporting..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
        Write-Host "Restricting Windows Update P2P only to local network..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
        Write-Host "Stopping and disabling Diagnostics Tracking Service..."
        Stop-Service "DiagTrack" -WarningAction SilentlyContinue
        Set-Service "DiagTrack" -StartupType Disabled
        Write-Host "Stopping and disabling WAP Push Service..."
        Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
        Set-Service "dmwappushservice" -StartupType Disabled
        Write-Host "Enabling F8 boot menu options..."
        bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
        Write-Host "Disabling Remote Assistance..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
        Write-Host "Stopping and disabling Superfetch service..."
        Stop-Service "SysMain" -WarningAction SilentlyContinue
        Set-Service "SysMain" -StartupType Disabled

        # Task Manager Details
        If ((get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild -lt 22557) {
            Write-Host "Showing task manager details..."
            $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
            Do {
                Start-Sleep -Milliseconds 100
                $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
            } Until ($preferences)
            Stop-Process $taskmgr
            $preferences.Preferences[28] = 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
        }
        else { Write-Host "Task Manager patch not run in builds 22557+ due to bug" }

        Write-Host "Showing file operations details..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
        Write-Host "Hiding Task View button..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
        Write-Host "Hiding People icon..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

        Write-Host "Changing default Explorer view to This PC..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

        ## Enable Long Paths
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWORD -Value 1

        Write-Host "Hiding 3D Objects icon from This PC..."
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue  

        ## Performance Tweaks and More Telemetry
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Type DWord -Value 400
        
        ## Timeout Tweaks cause flickering on Windows now
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LowLevelHooksTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillServiceTimeout" -ErrorAction SilentlyContinue

        # Network Tweaks
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type DWord -Value 20
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 4294967295

        # Gaming Tweaks
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Affinity" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Background Only" -Type String -Value "False"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Clock Rate" -Type DWord -Value 10000
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Type DWord -Value 8
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Type DWord -Value 6
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Type String -Value "High"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "SFIO Priority" -Type String -Value "High"

        # Group svchost.exe processes
        $ram = (Get-CimInstance -ClassName "Win32_PhysicalMemory" | Measure-Object -Property Capacity -Sum).Sum / 1kb
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force

        Write-Host "Disable News and Interests"
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
        # Remove "News and Interest" from taskbar
        Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

        # remove "Widgets" button from taskbar
        Write-Host "Disable Widgets"
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0

        # remove "Meet Now" button from taskbar

        If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
        }

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type DWord -Value 1

        Write-Host "Removing AutoLogger file and restricting directory..."
        $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
        If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
            Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
        }
        icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

        Write-Host "Stopping and disabling Diagnostics Tracking Service..."
        Stop-Service "DiagTrack"
        Set-Service "DiagTrack" -StartupType Disabled

        Write-Host "Doing Security checks for Administrator Account and Group Policy"
        if (([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).IndexOf('Administrator') -eq -1) {
            net user administrator /active:no
        }

        $wpf_DblTelemetry.IsChecked = $false
    }
    If ( $wpf_DblWifi.IsChecked -eq $true ) {
        Write-Host "Disabling Wi-Fi Sense..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
        $wpf_DblWifi.IsChecked = $false
    }
    If ( $wpf_DblAH.IsChecked -eq $true ) {
            Write-Host "Disabling Activity History..."
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
            $wpf_DblAH.IsChecked = $false
    }
    If ( $wpf_DblDeleteTempFiles.IsChecked -eq $true ) {
        Write-Host "Delete Temp Files"
        Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path $env:TEMP *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        $wpf_DblDeleteTempFiles.IsChecked = $false
        Write-Host "======================================="
        Write-Host "--- Cleaned following folders:"
        Write-Host "--- C:\Windows\Temp"
        Write-Host "--- "$env:TEMP
        Write-Host "======================================="
    }
    If ( $wpf_DblRecycleBin.IsChecked -eq $true ) {
        Write-Host "Empting Recycle Bin..." -ForegroundColor Green
        Clear-RecycleBin -Force
        $wpf_DblRecycleBin.IsChecked = $false
    }
    If ( $wpf_DblDiskCleanup.IsChecked -eq $true ) {
        Write-Host "Running Disk Cleanup on Drive C:..."
        cmd /c cleanmgr.exe /d C: /VERYLOWDISK
        $wpf_DblDiskCleanup.IsChecked = $false
    }
    If ( $wpf_DblLocTrack.IsChecked -eq $true ) {
        Write-Host "Disabling Location Tracking..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
        Write-Host "Disabling automatic Maps updates..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
        $wpf_DblLocTrack.IsChecked = $false
    }
    If ( $wpf_DblStorage.IsChecked -eq $true ) {
        Write-Host "Disabling Storage Sense..."
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
        $wpf_DblStorage.IsChecked = $false
    }
    If ( $wpf_DblHiber.IsChecked -eq $true  ) {
        Write-Host "Disabling Hibernation..."
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type Dword -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0
        $wpf_DblHiber.IsChecked = $false
    }
    If ( $wpf_DblDVR.IsChecked -eq $true ) {
        If (!(Test-Path "HKCU:\System\GameConfigStore")) {
            New-Item -Path "HKCU:\System\GameConfigStore" -Force
        }
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWord -Value 2
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

        $wpf_DblDVR.IsChecked = $false
    }
    If ( $wpf_DblCoreIsolation.IsChecked -eq $true ) {
        Write-Host "Disabling Core Isolation..." -ForegroundColor Green
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        $dwordName = "Enabled"
        # Value to set (0 to disable, 1 to enable)
        $dwordValue = 0

        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $dwordName -PropertyType DWord -Value $dwordValue -Force
        Write-Host "Core Isolation disabled." -ForegroundColor Green
        $wpf_DblCoreIsolation.IsChecked = $false
    }
    If ( $wpf_DblDisableTeredo.IsChecked -eq $true ) {
        Write-Host "Disabling Teredo..." -ForegroundColor Green
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
        $dwordName = "DisabledComponents"
        # Value to set (1 to disable, 0 to enable)
        $dwordValue = 1

        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $dwordName -PropertyType DWord -Value $dwordValue -Force
        Write-Host "netsh interface teredo set state disabled." -ForegroundColor Green
        $wpf_DblDisableTeredo.IsChecked = $false
    }
    If ( $wpf_DblAutoAdjustVolume.IsChecked -eq $true ) {
        Write-Host "Disabling Auto Adjust Volume..." -ForegroundColor Green
        $registryPath = "HKCU:\Software\Microsoft\Multimedia\Audio"
        $dwordName = "UserDuckingPreference"
        # dword:00000000: Mute all other sounds
        # dword:00000001: Reduce all other by 80%
        # dword:00000002: Reduce all other by 50%
        # dword:00000003: Do nothing
        $dwordValue = 3
        New-ItemProperty -Path $registryPath -Name $dwordName -PropertyType DWord -Value $dwordValue -Force
        $wpf_DblAutoAdjustVolume.IsChecked = $false
    }

    # Additional Tweaks
    If ( $wpf_DblPower.IsChecked -eq $true ) {
        If (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling") {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Type DWord -Value 00000001
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0000000
        $wpf_DblPower.IsChecked = $false 
    }
    If ( $wpf_DblDisplay.IsChecked -eq $true ) {
        # https://www.tenforums.com/tutorials/6377-change-visual-effects-settings-windows-10-a.html
        # https://superuser.com/questions/1244934/reg-file-to-modify-windows-10-visual-effects
        Write-Host "Adjusted visual effects for performance"
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name "FontSmoothing" -Value 2
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144, 18, 3, 128, 18, 0, 0, 0))
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1

        $wpf_DblDisplay.IsChecked = $false
    }
    If ( $wpf_DblUTC.IsChecked -eq $true ) {
        Write-Host "Setting BIOS time to UTC..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
        $wpf_DblUTC.IsChecked = $false
    }
    If ( $wpf_DblDisableUAC.IsChecked -eq $true) {
        Write-Host "Disabling UAC..."
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Type DWord -Value 0 # Default is 5
        # This will set the GPO Entry in Security so that Admin users elevate without any prompt while normal users still elevate and u can even leave it ennabled.
        $wpf_DblDisableUAC.IsChecked = $false
    }
    If ( $wpf_DblDisableNotifications.IsChecked -eq $true ) {
        Write-Host "Disabling Notifications and Action Center..."
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows" -Name "Explorer" -force
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -PropertyType "DWord" -Value 1
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -PropertyType "DWord" -Value 0 -force
        $wpf_DblDisableNotifications.IsChecked = $false
    }
    If ( $wpf_DblRemoveCortana.IsChecked -eq $true ) {
        Write-Host "Removing Cortana..."
        Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
        $wpf_DblRemoveCortana.IsChecked = $false
    }
    If ( $wpf_DblRemoveWidgets.IsChecked -eq $true ) {
        Write-Host "Removing Widgets..."
        Get-AppxPackage -allusers MicrosoftWindows.Client.WebExperience | Remove-AppxPackage
        $wpf_DblRemoveCortana.IsChecked = $false
    }
    If ( $wpf_DblClassicAltTab.IsChecked -eq $true ) {
        Write-Host "Setting Classic Alt+Tab..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3       
        $wpf_DblClassicAltTab.IsChecked = $false
    }
    If ( $wpf_DblRightClickMenu.IsChecked -eq $true ) {
        Write-Host "Setting Classic Right-Click Menu..."
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -force -value ""       
        $wpf_DblRightClickMenu.IsChecked = $false
    }
    If ( $wpf_DblGameMode.IsChecked -eq $true ) {
        Write-Host "Enabling Game Mode..."
        If (Test-Path HKCU:\Software\Microsoft\GameBar) {Get-Item HKCU:\Software\Microsoft\GameBar|Set-ItemProperty -Name AllowAutoGameMode -Value 1 -Verbose -Force}
        $wpf_DblGameMode.IsChecked -eq $false
    }
    If ( $wpf_DblGameBar.IsChecked -eq $true ) {
        Write-Host "Disabling Game Bar..."
        If (Test-Path "HKCU:\Software\Microsoft\GameBar") {Get-Item "HKCU:\Software\Microsoft\GameBar"|Set-ItemProperty -Name "UseNexusForGameBarEnabled" -Value 0 -Verbose -Force}
        $wpf_DblGameBar.IsChecked = $false
    }
    If ( $wpf_DblWindowsSound.IsChecked -eq $true ) {
        Write-Host "Disabling Windows Sound..." -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value ".None" -Force
        $wpf_DblWindowsSound.IsChecked = $false
    }
    If ( $wpf_DblPersonalize.IsChecked -eq $true ) {
        #hide search icon, show transparency effect, colors, lock screen, power
        Write-Host "Adjusting personalisation settings..."
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideTaskViewButton" -PropertyType "DWord" -Value 1 -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideTaskViewButton" -PropertyType "DWord" -Value 1 -Force
        
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -PropertyType "DWord" -Value 1 -Force
        
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoColorization" -PropertyType "DWord" -Value 0 -Force
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentColorMenu" -PropertyType "DWord" -Force -Value 0xffd47800
        #New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentPalette" -PropertyType "BINARY" -Force -Value '99,eb,ff,00,4c,c2,ff,00,00,91,f8,00,00,78,d4,00,00,67,c0,00,00,3e,92,00,00,1a,68,00,f7,63,0c,00'
        
        #Accent Palette Key
        $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
        $AccentPaletteKey = @{
            Key   = 'AccentPalette';
            Type  = "BINARY";
            Value = '99,eb,ff,00,4c,c2,ff,00,00,91,f8,00,00,78,d4,00,00,67,c0,00,00,3e,92,00,00,1a,68,00,f7,63,0c,00'
        }
        $hexified = $AccentPaletteKey.Value.Split(',') | ForEach-Object { "0x$_" }

        If ($Null -eq (Get-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -ErrorAction SilentlyContinue))
        {
            New-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -PropertyType Binary -Value ([byte[]]$hexified)
        }
        Else
        {
            Set-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -Value ([byte[]]$hexified) -Force
        }
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "StartColorMenu" -PropertyType "DWord" -Force -Value 0xffc06700
        
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -PropertyType "DWord" -Value 0 -Force
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -PropertyType "DWord" -Value 0 -Force

        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -PropertyType "DWord" -Force -Value 1
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenSlideshow" -PropertyType "DWord" -Force -Value 1
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -PropertyType "DWord" -Force -Value 1
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RemediationRequired" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314563Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -PropertyType "DWord" -Force -Value 0
        
        powercfg -x -disk-timeout-ac 0
        powercfg -x -disk-timeout-dc 0
        powercfg -x -monitor-timeout-ac 20
        powercfg -x -monitor-timeout-dc 20


        $wpf_DblPersonalize.IsChecked = $false
    }
    If ( $wpf_DblRemoveEdge.IsChecked -eq $true ) {
        # Standalone script by AveYo Source: https://raw.githubusercontent.com/AveYo/fox/main/Edge_Removal.bat

        curl.exe "https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/edgeremoval.bat" -o $ENV:temp\\edgeremoval.bat
        Start-Process $ENV:temp\\edgeremoval.bat

        $wpf_DblRemoveEdge.IsChecked= $false
    }
    If ( $wpf_DblOneDrive.IsChecked -eq $true ) {
        Write-Host "Kill OneDrive process"
        taskkill.exe /F /IM "OneDrive.exe"
        taskkill.exe /F /IM "explorer.exe"

        Write-Host "Copy all OneDrive to Root UserProfile"
        Start-Process -FilePath robocopy -ArgumentList "$env:USERPROFILE\OneDrive $env:USERPROFILE /e /xj" -NoNewWindow -Wait

        Write-Host "Remove OneDrive"
        Start-Process -FilePath winget -ArgumentList "uninstall -e --purge --force --silent Microsoft.OneDrive " -NoNewWindow -Wait

        Write-Host "Removing OneDrive leftovers"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"

        # check if directory is empty before removing:
        If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
        }

        # On clean installs or upgrades that never had one drive removed, that sidebar entry doesn't get removed
        # For now it break windows!!!

        # Write-Host "Remove Onedrive from explorer sidebar"
        # Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
        # Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0

        Write-Host "Removing run hook for new users"
        reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
        reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
        reg unload "hku\Default"

        Write-Host "Removing startmenu entry"
        Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

        Write-Host "Removing scheduled task"
        Get-ScheduledTask -TaskPath '\\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

        # Add Shell folders restoring default locations
        Write-Host "Shell Fixing"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "AppData" -Value "$env:userprofile\AppData\Roaming" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cache" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCache" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cookies" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCookies" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Favorites" -Value "$env:userprofile\Favorites" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "History" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\History" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Local AppData" -Value "$env:userprofile\AppData\Local" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Music" -Value "$env:userprofile\Music" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Video" -Value "$env:userprofile\Videos" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "NetHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Network Shortcuts" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "PrintHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Printer Shortcuts" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Programs" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Recent" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Recent" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "SendTo" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\SendTo" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Start Menu" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Startup" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Templates" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Templates" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "$env:userprofile\Downloads" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Value "$env:userprofile\Desktop" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures" -Value "$env:userprofile\Pictures" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value "$env:userprofile\Documents" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Value "$env:userprofile\Documents" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Value "$env:userprofile\Pictures" -Type ExpandString

        Write-Host "Restarting explorer"
        Start-Process "explorer.exe"

        Write-Host "Waiting for explorer to complete loading"
        Write-Host "Please Note - OneDrive folder may still have items in it. You must manually delete it, but all the files should already be copied to the base user folder."
        Start-Sleep 5

        $wpf_DblOneDrive.IsChecked = $false
    }
    if ( $wpf_DblModernCursorDark.IsChecked -eq $true ) {
        Write-Host "Downloading cursor..." -ForegroundColor Green
        $downloadUrl = "https://github.com/vukilis/Windows11-Optimizer-Debloater/raw/dev/cursor.zip" #github link
        $outputPath = "$env:TEMP\win11app"

        # Check if the file already exists
        if (-not (Test-Path -Path "$outputPath\cursor.zip")) {
            # File does not exist, download it
            New-Item -ItemType Directory -Force -Path $outputPath
            Invoke-WebRequest -Uri $downloadUrl -OutFile "$outputPath\cursor.zip"
            Write-Host "File downloaded to: $outputPath" -ForegroundColor Green
        } else {
            Write-Host "File already exists at: $outputPath" -ForegroundColor Magenta
        }

        # Unzip the downloaded file
        Write-Host "Unziping content..." -ForegroundColor Green
        Expand-Archive -Path "$outputPath\cursor.zip" -DestinationPath $outputPath -Force

        Write-Host "Installing cursor..." -ForegroundColor Green   
        # Step 2: Run install.inf
        $infPath = Join-Path $outputPath "dark\Install.inf"
        # Check if the install.inf file exists
        if (Test-Path $infPath) {
            # Run the installation file
            Start-Process "C:\Windows\System32\rundll32.exe" -ArgumentList "advpack.dll,LaunchINFSection $infPath,DefaultInstall"
        } else {
            Write-Host "Install.inf not found in the specified location."
        }

        # Set the cursor scheme values
        Write-Host "Seting cursor..." -ForegroundColor Green
        $cursorScheme = @"
C:\Windows\Cursors\Windows_11_dark_v2\pointer.cur,C:\Windows\Cursors\Windows_11_dark_v2\help.cur,C:\Windows\Cursors\Windows_11_dark_v2\working.ani,C:\Windows\Cursors\Windows_11_dark_v2\busy.ani,C:\Windows\Cursors\Windows_11_dark_v2\precision.cur,C:\Windows\Cursors\Windows_11_dark_v2\beam.cur,C:\Windows\Cursors\Windows_11_dark_v2\handwriting.cur,C:\Windows\Cursors\Windows_11_dark_v2\unavailable.cur,C:\Windows\Cursors\Windows_11_dark_v2\vert.cur,C:\Windows\Cursors\Windows_11_dark_v2\horz.cur,C:\Windows\Cursors\Windows_11_dark_v2\dgn1.cur,C:\Windows\Cursors\Windows_11_dark_v2\dgn2.cur,C:\Windows\Cursors\Windows_11_dark_v2\move.cur,C:\Windows\Cursors\Windows_11_dark_v2\alternate.cur,C:\Windows\Cursors\Windows_11_dark_v2\link.cur,C:\Windows\Cursors\Windows_11_dark_v2\person.cur,C:\Windows\Cursors\Windows_11_dark_v2\pin.cur
"@

        # Define the Registry path for the cursor scheme
        $registryPath = "HKCU:\Control Panel\Cursors"

        # Set the new cursor scheme for each individual cursor type
        $cursorTypes = @("AppStarting", "Arrow", "Crosshair", "Hand", "Help", "IBeam", "No", "NWPen", "SizeAll", "SizeNESW", "SizeNS", "SizeNWSE", "SizeWE", "UpArrow", "Wait")
        
        Write-Host "Updating cursor..." -ForegroundColor Green
        foreach ($cursorType in $cursorTypes) {
            Set-ItemProperty -Path $registryPath -Name $cursorType -Value $cursorScheme
        }

        Start-Sleep 1

        Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class SystemParamInfo
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

        [SystemParamInfo]::SystemParametersInfo(0x0057, 0, $null, 0)

    
        $wpf_DblModernCursorDark.IsChecked = $false
    }
    if ( $wpf_DblModernCursorLight.IsChecked -eq $true ) {
        Write-Host "Downloading cursor..." -ForegroundColor Green
        $downloadUrl = "https://github.com/vukilis/Windows11-Optimizer-Debloater/raw/dev/cursor.zip" #github link
        $outputPath = "$env:TEMP\win11app"

        # Check if the file already exists
        if (-not (Test-Path -Path "$outputPath\cursor.zip")) {
            # File does not exist, download it
            New-Item -ItemType Directory -Force -Path $outputPath
            Invoke-WebRequest -Uri $downloadUrl -OutFile "$outputPath\cursor.zip"
            Write-Host "File downloaded to: $outputPath" -ForegroundColor Green
        } else {
            Write-Host "File already exists at: $outputPath" -ForegroundColor Magenta
        }

        # Unzip the downloaded file
        Write-Host "Unziping content..." -ForegroundColor Green
        Expand-Archive -Path "$outputPath\cursor.zip" -DestinationPath $outputPath -Force

        Write-Host "Installing cursor..." -ForegroundColor Green   
        # Step 2: Run install.inf
        $infPath = Join-Path $outputPath "light\Install.inf"
        # Check if the install.inf file exists
        if (Test-Path $infPath) {
            # Run the installation file
            Start-Process "C:\Windows\System32\rundll32.exe" -ArgumentList "advpack.dll,LaunchINFSection $infPath,DefaultInstall"
        } else {
            Write-Host "Install.inf not found in the specified location."
        }

        # Set the cursor scheme values
        Write-Host "Seting cursor..." -ForegroundColor Green
        $cursorScheme = @"
C:\Windows\Cursors\Windows_11_light_v2\pointer.cur,C:\Windows\Cursors\Windows_11_light_v2\help.cur,C:\Windows\Cursors\Windows_11_light_v2\working.ani,C:\Windows\Cursors\Windows_11_light_v2\busy.ani,C:\Windows\Cursors\Windows_11_light_v2\precision.cur,C:\Windows\Cursors\Windows_11_light_v2\beam.cur,C:\Windows\Cursors\Windows_11_light_v2\handwriting.cur,C:\Windows\Cursors\Windows_11_light_v2\unavailable.cur,C:\Windows\Cursors\Windows_11_light_v2\vert.cur,C:\Windows\Cursors\Windows_11_light_v2\horz.cur,C:\Windows\Cursors\Windows_11_light_v2\dgn1.cur,C:\Windows\Cursors\Windows_11_light_v2\dgn2.cur,C:\Windows\Cursors\Windows_11_light_v2\move.cur,C:\Windows\Cursors\Windows_11_light_v2\alternate.cur,C:\Windows\Cursors\Windows_11_light_v2\link.cur,C:\Windows\Cursors\Windows_11_light_v2\person.cur,C:\Windows\Cursors\Windows_11_light_v2\pin.cur
"@

        # Define the Registry path for the cursor scheme
        $registryPath = "HKCU:\Control Panel\Cursors"

        # Set the new cursor scheme for each individual cursor type
        $cursorTypes = @("AppStarting", "Arrow", "Crosshair", "Hand", "Help", "IBeam", "No", "NWPen", "SizeAll", "SizeNESW", "SizeNS", "SizeNWSE", "SizeWE", "UpArrow", "Wait")
        
        Write-Host "Updating cursor..." -ForegroundColor Green
        foreach ($cursorType in $cursorTypes) {
            Set-ItemProperty -Path $registryPath -Name $cursorType -Value $cursorScheme
        }

        Start-Sleep 1

        Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class SystemParamInfo
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

        [SystemParamInfo]::SystemParametersInfo(0x0057, 0, $null, 0)

    
        $wpf_DblModernCursorLight.IsChecked = $false
    }
    Invoke-MessageBox -msg "tweak"
    # Invoke restart computer
    If ( $wpf_DblRestartPC.IsChecked -eq $true ) {
        Restart-Computer
    }
}