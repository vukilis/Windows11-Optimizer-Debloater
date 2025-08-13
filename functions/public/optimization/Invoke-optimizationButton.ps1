function Invoke-OptimizationButton {
    <#
    .SYNOPSIS
        Applies all selected CheckBox tweaks dynamically and resets their state.
    #>

    # Loop through all tweaks
    foreach ($toggleName in $tweaks.PSObject.Properties.Name) {
        $tweak = $tweaks.$toggleName

        $apply = $false

        switch ($tweak.Type) {
            "ScheduledTask" {
                $apply = $true
            }
            "CheckBox" {
                $controlVar = Get-Variable -Name "wpf_$toggleName" -ErrorAction SilentlyContinue
                if ($controlVar) {
                    $apply = [bool]$controlVar.Value.IsChecked
                } elseif ($tweak.DefaultState) {
                    $apply = [bool]$tweak.DefaultState
                }
            }
            "InvokeScript" {
                $apply = $true
            }
        }

        # Apply registry changes if available and checkbox/toggle is checked
        if ($apply) {
            if ($tweak.ScheduledTask) {
                Write-Host "ScheduledTask:" $tweak.message -ForegroundColor Green
                foreach ($task in $tweak.ScheduledTask) {
                    try {
                        Set-ScheduledTask -Name $task.Name -State $task.State
                    } catch {
                        Write-Warning "Failed to set scheduled task '$($task.Name)' to $($task.State): $_"
                    }
                }
            }

            if ($tweak.Registry) {
                Write-Host "Registry:" $tweak.message -ForegroundColor Green
                foreach ($regEntry in $tweak.Registry) {
                    try { 
                        Set-RegistryValue -Path $regEntry.Path -Name $regEntry.Name -Type $regEntry.Type -Value $regEntry.Value }
                    catch { 
                        Write-Warning "Failed to apply registry tweak: $_" }
                }
            }
            if ($tweak.InvokeScript) {
                Write-Host "InvokeScript:" $tweak.message -ForegroundColor Green
                foreach ($script in $tweak.InvokeScript) {
                    Invoke-Expression $script
                }
            }
        }

    }

    Invoke-MessageBox -msg "tweak"
}


# function Invoke-optimizationButton{
#     <#

#     .SYNOPSIS
#         This function run selected tweaks
#         Unselect tweaks after tweaking
#     #>

#     # Invoke restore point
#     If ( $wpf_DblSystemRestore.IsChecked -eq $true ) {
#         Write-Host "Making Restore Point..." -ForegroundColor Green
#         Set-RestorePoint
#     }
#     # Essential Tweaks
#     If ( $wpf_DblTelemetry.IsChecked -eq $true ) {
#         Write-Host "Disabling Telemetry..." -ForegroundColor Green
#         Set-ScheduledTask -Name "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Application Experience\ProgramDataUpdater" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Autochk\Proxy" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Feedback\Siuf\DmClient" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Windows Error Reporting\QueueReporting" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Application Experience\MareBackup" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Application Experience\StartupAppTask" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Application Experience\PcaPatchDbTask" -State "Disabled"
#         Set-ScheduledTask -Name "Microsoft\Windows\Maps\MapsUpdateTask" -State "Disabled"
        
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PeopleBand" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LongPathsEnabled" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type "DWord" -Value 4294967295
#         Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type "DWord" -Value 2
#         Set-RegistryValue -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Type "DWord" -Value 400
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type "DWord" -Value 30
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type "DWord" -Value 2
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type "DWord" -Value 0
        
#         $InvokeScript = [ScriptBlock]::Create(@'
# bcdedit /set {current} bootmenupolicy Legacy | Out-Null

# If ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild -lt 22557) {
#     $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
#     Do {
#         Start-Sleep -Milliseconds 100
#         $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
#     } Until ($preferences)
#     Stop-Process $taskmgr
#     $preferences.Preferences[28] = 0
#     Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
# }

# Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue

# If (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge") {
#     Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Recurse -ErrorAction SilentlyContinue
# }

# $ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1kb
# Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force

# $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
# If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
#     Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
# }
# icacls $autoLoggerDir "/deny" "SYSTEM:(OI)(CI)F" | Out-Null

# Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue | Out-Null
# '@)

#         Invoke-Scripts -ScriptBlock $InvokeScript -Name "InvokeScript"


#         $wpf_DblTelemetry.IsChecked = $false
#     }
#     If ( $wpf_DblWifi.IsChecked -eq $true ) {
#         Write-Host "Disabling Wi-Fi Sense..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type "DWord" -Value 0
#         $wpf_DblWifi.IsChecked = $false
#     }
#     If ( $wpf_DblAH.IsChecked -eq $true ) {
#             Write-Host "Disabling Activity History..." -ForegroundColor Green
#             Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type "DWord" -Value 0
#             Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type "DWord" -Value 0
#             Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type "DWord" -Value 0
#             $wpf_DblAH.IsChecked = $false
#     }
#     If ( $wpf_DblDeleteTempFiles.IsChecked -eq $true ) {
#         Write-Host "Delete Temp Files" -ForegroundColor Green
#         Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
#         Get-ChildItem -Path $env:TEMP *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
#         $wpf_DblDeleteTempFiles.IsChecked = $false
#         Write-Host "======================================="
#         Write-Host "--- Cleaned following folders:"
#         Write-Host "--- C:\Windows\Temp"
#         Write-Host "--- "$env:TEMP
#         Write-Host "======================================="
#     }
#     If ( $wpf_DblRecycleBin.IsChecked -eq $true ) {
#         Write-Host "Empting Recycle Bin..." -ForegroundColor Green
#         Clear-RecycleBin -Force
#         $wpf_DblRecycleBin.IsChecked = $false
#     }
#     If ( $wpf_DblDiskCleanup.IsChecked -eq $true ) {
#         Write-Host "Running Disk Cleanup on Drive C:..." -ForegroundColor Green
#         cmd /c cleanmgr.exe /d C: /VERYLOWDISK
#         $wpf_DblDiskCleanup.IsChecked = $false
#     }
#     If ( $wpf_DblLocTrack.IsChecked -eq $true ) {
#         Write-Host "Disabling Location Tracking..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Deny"
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type "DWord" -Value 0

#         $wpf_DblLocTrack.IsChecked = $false
#     }
#     If ( $wpf_DblStorage.IsChecked -eq $true ) {
#         Write-Host "Disabling Storage Sense..." -ForegroundColor Green
#         Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 0 -Type Dword -Force
#         $wpf_DblStorage.IsChecked = $false
#     }
#     If ( $wpf_DblHiber.IsChecked -eq $true  ) {
#         Write-Host "Disabling Hibernation..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type "Dword" -Value 0
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type "Dword" -Value 0
        
#         $InvokeScript = [ScriptBlock]::Create(@'
#         powercfg.exe /hibernate off
# '@)
#         Invoke-Scripts -ScriptBlock $InvokeScript -Name "InvokeScript"
#         $wpf_DblHiber.IsChecked = $false
#     }
#     If ( $wpf_DblDVR.IsChecked -eq $true ) {
#         Write-Host "Disabling GameDVR..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type "DWord" -Value 2
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type "DWord" -Value 0
#         $wpf_DblDVR.IsChecked = $false
#     }
#     If ( $wpf_DblCoreIsolation.IsChecked -eq $true ) {
#         Write-Host "Disabling Core Isolation..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type "DWord" -Value 0
#         $wpf_DblCoreIsolation.IsChecked = $false
#     }
#     If ( $wpf_DblDisableTeredo.IsChecked -eq $true ) {
#         Write-Host "Disabling Teredo..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Type "DWord" -Value 1
#         $wpf_DblDisableTeredo.IsChecked = $false
#     }
#     If ( $wpf_DblAutoAdjustVolume.IsChecked -eq $true ) {
#         Write-Host "Disabling Auto Adjust Volume..." -ForegroundColor Green
#         # dword:00000000: Mute all other sounds
#         # dword:00000001: Reduce all other by 80%
#         # dword:00000002: Reduce all other by 50%
#         # dword:00000003: Do nothing
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Multimedia\Audio" -Name "UserDuckingPreference" -Type "DWord" -Value 3
#         $wpf_DblAutoAdjustVolume.IsChecked = $false
#     }
#     If ( $wpf_DblSearchIndexer.IsChecked -eq $true ) {
#         Write-Host "Disabling search indexer..." -ForegroundColor Green
#         Get-Service -Name "wsearch" -ErrorAction SilentlyContinue | Stop-Service -ErrorAction SilentlyContinue
#         Get-Service -Name "wsearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
#         $wpf_DblSearchIndexer.IsChecked = $false
#     }
#     If ( $wpf_DblPS7Telemetry.IsChecked -eq $true ) {
#         Write-Host "Disabling Powershell 7 Telemetry..." -ForegroundColor Green
#         "[Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', 'Machine')"
#         $wpf_DblPS7Telemetry.IsChecked = $false
#     }
#     If ( $wpf_DblConsumerFeatures.IsChecked -eq $true ) {
#         Write-Host "Disabling ConsumerFeatures..." -ForegroundColor Green 
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type "DWord" -Value 1
#         $wpf_DblConsumerFeatures.IsChecked = $false
#     }

#     # Additional Tweaks
#     If ( $wpf_DblPower.IsChecked -eq $true ) {
#         Write-Host "Disabling Power Throttling..." -ForegroundColor Green        
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type "DWord" -Value 0
#         $wpf_DblPower.IsChecked = $false 
#     }
#     If ( $wpf_DblDisplay.IsChecked -eq $true ) {
#         # https://www.tenforums.com/tutorials/6377-change-visual-effects-settings-windows-10-a.html
#         # https://superuser.com/questions/1244934/reg-file-to-modify-windows-10-visual-effects
#         Write-Host "Adjusted visual effects for performance" -ForegroundColor Green        
#         Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type "String" -Value 1
#         Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "String" -Value 0
#         Set-RegistryValue -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type "String" -Value 0
#         Set-RegistryValue -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type "DWord" -Value 3
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type "DWord" -Value 1

#         $InvokeScript = [ScriptBlock]::Create(@'
#         Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144, 18, 3, 128, 18, 0, 0, 0))
# '@)
#         Invoke-Scripts -ScriptBlock $InvokeScript -Name "InvokeScript"
#         $wpf_DblDisplay.IsChecked = $false
#     }
#     If ( $wpf_DblUTC.IsChecked -eq $true ) {
#         Write-Host "Setting BIOS time to UTC..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type "DWord" -Value 1
#         $wpf_DblUTC.IsChecked = $false
#     }
#     If ( $wpf_DblDisableUAC.IsChecked -eq $true) {
#         Write-Host "Disabling UAC..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type "DWord" -Value 0 # Default is 5
#         # This will set the GPO Entry in Security so that Admin users elevate without any prompt while normal users still elevate and u can even leave it ennabled.
#         $wpf_DblDisableUAC.IsChecked = $false
#     }
#     If ( $wpf_DblDisableNotifications.IsChecked -eq $true ) {
#         Write-Host "Disabling Notification Tray/Calendar..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value 0
#         $wpf_DblDisableNotifications.IsChecked = $false
#     }
#     If ( $wpf_DblRemoveCortana.IsChecked -eq $true ) {
#         Write-Host "Removing Cortana..."
#         Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
#         $wpf_DblRemoveCortana.IsChecked = $false
#     }
#     If ( $wpf_DblRemoveWidgets.IsChecked -eq $true ) {
#         Write-Host "Removing Widgets..."
#         Get-AppxPackage -allusers MicrosoftWindows.Client.WebExperience | Remove-AppxPackage
#         $wpf_DblRemoveWidgets.IsChecked = $false
#     }
#     If ( $wpf_DblClassicAltTab.IsChecked -eq $true ) {
#         Write-Host "Setting Classic Alt+Tab..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type "DWord" -Value 3       
#         $wpf_DblClassicAltTab.IsChecked = $false
#     }
#     If ( $wpf_DblRightClickMenu.IsChecked -eq $true ) {
#         Write-Host "Setting Classic Right-Click Menu..." -ForegroundColor Green
#         Write-Host Restarting explorer.exe ... -ForegroundColor Blue
#         taskkill.exe /F /IM "explorer.exe"
#         New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -force -value ""       
#         Start-Process "explorer.exe"
#         $wpf_DblRightClickMenu.IsChecked = $false
#     }
#     If ( $wpf_DblGameMode.IsChecked -eq $true ) {
#         Write-Host "Enabling Game Mode..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type "DWord" -Value 3       
#         $wpf_DblGameMode.IsChecked -eq $false
#     }
#     If ( $wpf_DblGameBar.IsChecked -eq $true ) {
#         Write-Host "Disabling Game Bar..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type "DWord" -Value 0      
#         $wpf_DblGameBar.IsChecked = $false
#     }
#     If ( $wpf_DblWindowsSound.IsChecked -eq $true ) {
#         Write-Host "Disabling Windows Sound..." -ForegroundColor Green
#         Set-RegistryValue -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Type "String" -Value ".None"
#         $wpf_DblWindowsSound.IsChecked = $false
#     }
#     If ( $wpf_DblPersonalize.IsChecked -eq $true ) {
#         Write-Host "Adjusting Personalization Settings..." -ForegroundColor Green       
#         #hide search icon, show transparency effect, colors, lock screen, power
#         Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideTaskViewButton" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideTaskViewButton" -Type "DWord" -Value 1
        
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type "DWord" -Value 1
        
#         Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "AutoColorization" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentColorMenu" -Type "DWord" -Value 0xffd47800

#         $InvokeScript = [ScriptBlock]::Create(@'
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentPalette" -Type Binary -Value ([byte[]](0x99,0xEB,0xFF,0x00,0x41,0xF8,0x00,0x00,0x78,0xD4,0x00,0x00,0x67,0xC0,0x00,0x00,0x3E,0x92,0x00,0x00,0x1A,0x68,0x00,0xF7,0x63,0x0C,0x00))
# '@)
#         Invoke-Scripts -ScriptBlock $InvokeScript -Name "InvokeScript"

#         Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "StartColorMenu" -Type "DWord" -Value 0xffc06700
        
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type "DWord" -Value 0

#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenSlideshow" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type "DWord" -Value 1
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RemediationRequired" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314563Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type "DWord" -Value 0
#         Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -Type "DWord" -Value 0

        
#         powercfg -x -disk-timeout-ac 0
#         powercfg -x -disk-timeout-dc 0
#         powercfg -x -monitor-timeout-ac 20
#         powercfg -x -monitor-timeout-dc 20


#         $wpf_DblPersonalize.IsChecked = $false
#     }
#     If ( $wpf_DblRemoveEdge.IsChecked -eq $true ) {
#         # Standalone script by AveYo Source: https://raw.githubusercontent.com/AveYo/fox/main/Edge_Removal.bat

#         curl.exe "https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/edgeremoval.bat" -o $ENV:temp\\edgeremoval.bat
#         Start-Process $ENV:temp\\edgeremoval.bat

#         $wpf_DblRemoveEdge.IsChecked= $false
#     }
#     If ( $wpf_DblOneDrive.IsChecked -eq $true ) {
#         $InvokeScript = [ScriptBlock]::Create(@'
        
#         $OneDrivePath = $($env:OneDrive)
#         Write-Host "Removing OneDrive" -ForegroundColor Green
#         $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe"
#         if (Test-Path $regPath) {
#             $OneDriveUninstallString = Get-ItemPropertyValue "$regPath" -Name "UninstallString"
#             $OneDriveExe, $OneDriveArgs = $OneDriveUninstallString.Split(" ")
#             Start-Process -FilePath $OneDriveExe -ArgumentList "$OneDriveArgs /silent" -NoNewWindow -Wait
#         } else {
#             Write-Host "Onedrive dosn't seem to be installed anymore" -ForegroundColor Red
#             return
#         }
#         # Check if OneDrive got Uninstalled
#         if (-not (Test-Path $regPath)) {
#         Write-Host "Copy downloaded Files from the OneDrive Folder to Root UserProfile"
#         Start-Process -FilePath powershell -ArgumentList "robocopy '$($OneDrivePath)' '$($env:USERPROFILE.TrimEnd())\' /mov /e /xj" -NoNewWindow -Wait

#         Write-Host "Removing OneDrive leftovers"
#         Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
#         Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\OneDrive"
#         Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
#         Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
#         reg delete "HKEY_CURRENT_USER\Software\Microsoft\OneDrive" -f
#         # check if directory is empty before removing:
#         If ((Get-ChildItem "$OneDrivePath" -Recurse | Measure-Object).Count -eq 0) {
#             Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$OneDrivePath"
#         }

#         Write-Host "Remove Onedrive from explorer sidebar"
#         Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
#         Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0

#         Write-Host "Removing run hook for new users"
#         reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
#         reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
#         reg unload "hku\Default"

#         Write-Host "Removing startmenu entry"
#         Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

#         Write-Host "Removing scheduled task"
#         Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

#         # Add Shell folders restoring default locations
#         Write-Host "Shell Fixing"
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "AppData" -Value "$env:userprofile\AppData\Roaming" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cache" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCache" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cookies" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCookies" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Favorites" -Value "$env:userprofile\Favorites" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "History" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\History" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Local AppData" -Value "$env:userprofile\AppData\Local" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Music" -Value "$env:userprofile\Music" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Video" -Value "$env:userprofile\Videos" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "NetHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Network Shortcuts" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "PrintHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Printer Shortcuts" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Programs" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Recent" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Recent" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "SendTo" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\SendTo" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Start Menu" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Startup" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Templates" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Templates" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "$env:userprofile\Downloads" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Value "$env:userprofile\Desktop" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures" -Value "$env:userprofile\Pictures" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value "$env:userprofile\Documents" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Value "$env:userprofile\Documents" -Type ExpandString
#         Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Value "$env:userprofile\Pictures" -Type ExpandString
#         Write-Host "Restarting explorer"
#         taskkill.exe /F /IM "explorer.exe"
#         Start-Process "explorer.exe"

#         Write-Host "Waiting for explorer to complete loading"
#         Write-Host "Please Note - The OneDrive folder at $OneDrivePath may still have items in it. You must manually delete it, but all the files should already be copied to the base user folder."
#         Write-Host "If there are Files missing afterwards, please Login to Onedrive.com and Download them manually" -ForegroundColor Yellow
#         Start-Sleep 5
#         } else {
#             Write-Host "Something went Wrong during the Unistallation of OneDrive" -ForegroundColor Red
#         }
# '@)
#         Invoke-Scripts -ScriptBlock $InvokeScript -Name "InvokeScript"

#         $wpf_DblOneDrive.IsChecked = $false
#     }
#     if ( $wpf_DblModernCursorDark.IsChecked -eq $true ) {
#         Write-Host "Downloading cursor..." -ForegroundColor Green
#         $downloadUrl = "https://github.com/vukilis/Windows11-Optimizer-Debloater/raw/dev/cursor.zip" #github link
#         $outputPath = "$env:TEMP\win11app"

#         # Check if the file already exists
#         if (-not (Test-Path -Path "$outputPath\cursor.zip")) {
#             # File does not exist, download it
#             New-Item -ItemType Directory -Force -Path $outputPath
#             Invoke-WebRequest -Uri $downloadUrl -OutFile "$outputPath\cursor.zip"
#             Write-Host "File downloaded to: $outputPath" -ForegroundColor Green
#         } else {
#             Write-Host "File already exists at: $outputPath" -ForegroundColor Magenta
#         }

#         # Unzip the downloaded file
#         Write-Host "Unziping content..." -ForegroundColor Green
#         Expand-Archive -Path "$outputPath\cursor.zip" -DestinationPath $outputPath -Force

#         Write-Host "Installing cursor..." -ForegroundColor Green   
#         # Step 2: Run install.inf
#         $infPath = Join-Path $outputPath "dark\Install.inf"
#         # Check if the install.inf file exists
#         if (Test-Path $infPath) {
#             # Run the installation file
#             Start-Process "C:\Windows\System32\rundll32.exe" -ArgumentList "advpack.dll,LaunchINFSection $infPath,DefaultInstall"
#         } else {
#             Write-Host "Install.inf not found in the specified location."
#         }

#         # Set the cursor scheme values
#         Write-Host "Seting cursor..." -ForegroundColor Green
#         $cursorScheme = @"
# C:\Windows\Cursors\Windows_11_dark_v2\pointer.cur,C:\Windows\Cursors\Windows_11_dark_v2\help.cur,C:\Windows\Cursors\Windows_11_dark_v2\working.ani,C:\Windows\Cursors\Windows_11_dark_v2\busy.ani,C:\Windows\Cursors\Windows_11_dark_v2\precision.cur,C:\Windows\Cursors\Windows_11_dark_v2\beam.cur,C:\Windows\Cursors\Windows_11_dark_v2\handwriting.cur,C:\Windows\Cursors\Windows_11_dark_v2\unavailable.cur,C:\Windows\Cursors\Windows_11_dark_v2\vert.cur,C:\Windows\Cursors\Windows_11_dark_v2\horz.cur,C:\Windows\Cursors\Windows_11_dark_v2\dgn1.cur,C:\Windows\Cursors\Windows_11_dark_v2\dgn2.cur,C:\Windows\Cursors\Windows_11_dark_v2\move.cur,C:\Windows\Cursors\Windows_11_dark_v2\alternate.cur,C:\Windows\Cursors\Windows_11_dark_v2\link.cur,C:\Windows\Cursors\Windows_11_dark_v2\person.cur,C:\Windows\Cursors\Windows_11_dark_v2\pin.cur
# "@

#         # Define the Registry path for the cursor scheme
#         $registryPath = "HKCU:\Control Panel\Cursors"

#         # Set the new cursor scheme for each individual cursor type
#         $cursorTypes = @("AppStarting", "Arrow", "Crosshair", "Hand", "Help", "IBeam", "No", "NWPen", "SizeAll", "SizeNESW", "SizeNS", "SizeNWSE", "SizeWE", "UpArrow", "Wait")
        
#         Write-Host "Updating cursor..." -ForegroundColor Green
#         foreach ($cursorType in $cursorTypes) {
#             Set-ItemProperty -Path $registryPath -Name $cursorType -Value $cursorScheme
#         }

#         Start-Sleep 1

#         Add-Type @"
#     using System;
#     using System.Runtime.InteropServices;

#     public class SystemParamInfo
#     {
#         [DllImport("user32.dll", CharSet = CharSet.Unicode)]
#         public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
#     }
# "@

#         [SystemParamInfo]::SystemParametersInfo(0x0057, 0, $null, 0)

    
#         $wpf_DblModernCursorDark.IsChecked = $false
#     }
#     if ( $wpf_DblModernCursorLight.IsChecked -eq $true ) {
#         Write-Host "Downloading cursor..." -ForegroundColor Green
#         $downloadUrl = "https://github.com/vukilis/Windows11-Optimizer-Debloater/raw/dev/cursor.zip" #github link
#         $outputPath = "$env:TEMP\win11app"

#         # Check if the file already exists
#         if (-not (Test-Path -Path "$outputPath\cursor.zip")) {
#             # File does not exist, download it
#             New-Item -ItemType Directory -Force -Path $outputPath
#             Invoke-WebRequest -Uri $downloadUrl -OutFile "$outputPath\cursor.zip"
#             Write-Host "File downloaded to: $outputPath" -ForegroundColor Green
#         } else {
#             Write-Host "File already exists at: $outputPath" -ForegroundColor Magenta
#         }

#         # Unzip the downloaded file
#         Write-Host "Unziping content..." -ForegroundColor Green
#         Expand-Archive -Path "$outputPath\cursor.zip" -DestinationPath $outputPath -Force

#         Write-Host "Installing cursor..." -ForegroundColor Green   
#         # Step 2: Run install.inf
#         $infPath = Join-Path $outputPath "light\Install.inf"
#         # Check if the install.inf file exists
#         if (Test-Path $infPath) {
#             # Run the installation file
#             Start-Process "C:\Windows\System32\rundll32.exe" -ArgumentList "advpack.dll,LaunchINFSection $infPath,DefaultInstall"
#         } else {
#             Write-Host "Install.inf not found in the specified location."
#         }

#         # Set the cursor scheme values
#         Write-Host "Seting cursor..." -ForegroundColor Green
#         $cursorScheme = @"
# C:\Windows\Cursors\Windows_11_light_v2\pointer.cur,C:\Windows\Cursors\Windows_11_light_v2\help.cur,C:\Windows\Cursors\Windows_11_light_v2\working.ani,C:\Windows\Cursors\Windows_11_light_v2\busy.ani,C:\Windows\Cursors\Windows_11_light_v2\precision.cur,C:\Windows\Cursors\Windows_11_light_v2\beam.cur,C:\Windows\Cursors\Windows_11_light_v2\handwriting.cur,C:\Windows\Cursors\Windows_11_light_v2\unavailable.cur,C:\Windows\Cursors\Windows_11_light_v2\vert.cur,C:\Windows\Cursors\Windows_11_light_v2\horz.cur,C:\Windows\Cursors\Windows_11_light_v2\dgn1.cur,C:\Windows\Cursors\Windows_11_light_v2\dgn2.cur,C:\Windows\Cursors\Windows_11_light_v2\move.cur,C:\Windows\Cursors\Windows_11_light_v2\alternate.cur,C:\Windows\Cursors\Windows_11_light_v2\link.cur,C:\Windows\Cursors\Windows_11_light_v2\person.cur,C:\Windows\Cursors\Windows_11_light_v2\pin.cur
# "@

#         # Define the Registry path for the cursor scheme
#         $registryPath = "HKCU:\Control Panel\Cursors"

#         # Set the new cursor scheme for each individual cursor type
#         $cursorTypes = @("AppStarting", "Arrow", "Crosshair", "Hand", "Help", "IBeam", "No", "NWPen", "SizeAll", "SizeNESW", "SizeNS", "SizeNWSE", "SizeWE", "UpArrow", "Wait")
        
#         Write-Host "Updating cursor..." -ForegroundColor Green
#         foreach ($cursorType in $cursorTypes) {
#             Set-ItemProperty -Path $registryPath -Name $cursorType -Value $cursorScheme
#         }

#         Start-Sleep 1

#         Add-Type @"
#     using System;
#     using System.Runtime.InteropServices;

#     public class SystemParamInfo
#     {
#         [DllImport("user32.dll", CharSet = CharSet.Unicode)]
#         public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
#     }
# "@

#         [SystemParamInfo]::SystemParametersInfo(0x0057, 0, $null, 0)

    
#         $wpf_DblModernCursorLight.IsChecked = $false
#     }
#     Invoke-MessageBox -msg "tweak"
#     # Invoke restart computer
#     If ( $wpf_DblRestartPC.IsChecked -eq $true ) {
#         Restart-Computer
#     }
# }