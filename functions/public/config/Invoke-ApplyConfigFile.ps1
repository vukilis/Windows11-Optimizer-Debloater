function Invoke-ApplyConfigFile {
    <#
    .SYNOPSIS
        Applies a configuration JSON file without launching the GUI.
    .PARAMETER ConfigPath
        Path to the configuration JSON file.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath
    )

    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Config file not found: $ConfigPath"
        return $false
    }

    try {
        $config = Get-Content -Path $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json
    } catch {
        Write-Error "Failed to parse config file: $_"
        return $false
    }

    Write-Host "Applying configuration from: $ConfigPath" -ForegroundColor Cyan

    # Apply DNS settings
    if ($config.PSObject.Properties.Name -contains 'dns' -and $config.dns) {
        Write-Host "Applying DNS: $($config.dns.provider)" -ForegroundColor Yellow
        Invoke-ApplyDNS -Provider $config.dns.provider
    }

    # Apply services mode
    if ($config.PSObject.Properties.Name -contains 'services' -and $config.services) {
        Write-Host "Applying Services mode: $($config.services.mode)" -ForegroundColor Yellow
        Invoke-ServicePreset -Mode $config.services.mode
    }

    # Apply updates mode
    if ($config.PSObject.Properties.Name -contains 'updates' -and $config.updates) {
        Write-Host "Applying Updates mode: $($config.updates.mode)" -ForegroundColor Yellow
        switch ($config.updates.mode) {
            "default" { Invoke-UpdatesDefault }
            "pause" { Invoke-PauseUpdate }
            "fixes" { Invoke-FixesUpdate }
            "disable" { Invoke-UpdatesDisable }
            "security" { Invoke-UpdatesSecurity }
        }
    }

    # Apply checked tweaks
    if ($config.PSObject.Properties.Name -contains 'tweaks' -and $config.tweaks) {
        Write-Host "Applying tweaks..." -ForegroundColor Yellow
        foreach ($toggleName in $config.tweaks.PSObject.Properties.Name) {
            if ($config.tweaks.$toggleName -eq $true) {
                Write-Host "  Applying tweak: $toggleName" -ForegroundColor Gray
                $tweak = $sync.configs.tweaks.$toggleName
                if ($tweak) {
                    # Handle ScheduledTask tweaks
                    if ($tweak.PSObject.Properties.Name -contains 'ScheduledTask' -and $tweak.ScheduledTask) {
                        foreach ($task in $tweak.ScheduledTask) {
                            try {
                                Set-ScheduledTask -Name $task.Name -State $task.State
                            } catch {
                                Write-Warning "Failed to set scheduled task '$($task.Name)' to $($task.State): $_"
                            }
                        }
                    }

                    # Handle registry tweaks
                    if ($tweak.PSObject.Properties.Name -contains 'registry' -and $tweak.registry) {
                        foreach ($regEntry in $tweak.registry) {
                            try {
                                Set-RegistryValue -Path $regEntry.Path -Name $regEntry.Name -Type $regEntry.Type -Value $regEntry.Value
                            } catch {
                                Write-Warning "Failed to apply registry tweak: $_"
                            }
                        }
                    }

                    # Handle service tweaks
                    if ($tweak.PSObject.Properties.Name -contains 'service' -and $tweak.service) {
                        foreach ($service in $tweak.service) {
                            try {
                                Set-WinService -Name $service.Name -StartupType $service.StartupType
                            } catch {
                                Write-Warning "Failed to set service '$($service.Name)' to $($service.StartupType): $_"
                            }
                        }
                    }

                    # Handle InvokeScript tweaks
                    if ($tweak.PSObject.Properties.Name -contains 'InvokeScript' -and $tweak.InvokeScript) {
                        foreach ($script in $tweak.InvokeScript) {
                            Invoke-Scripts -Name $tweak.Content -Script $script
                        }
                    }
                }
            }
        }
    }

    # Apply features
    if ($config.PSObject.Properties.Name -contains 'features' -and $config.features) {
        Write-Host "Applying features..." -ForegroundColor Yellow
        foreach ($featureName in $config.features.PSObject.Properties.Name) {
            if ($config.features.$featureName -eq $true) {
                Write-Host "  Applying feature: $featureName" -ForegroundColor.Gray
                $feature = $sync.configs.feature.$featureName
                if ($feature) {
                    switch ($feature.Type) {
                        "CheckBox" {
                            # Features are handled by their individual functions
                            if ($feature.PSObject.Properties.Name -contains 'InvokeScript' -and $feature.InvokeScript) {
                                foreach ($script in $feature.InvokeScript) {
                                    Invoke-Scripts -Name $feature.Content -Script $script
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    # Apply debloated apps
    if ($config.PSObject.Properties.Name -contains 'debloatedApps' -and $config.debloatedApps) {
        Write-Host "Removing debloated apps..." -ForegroundColor Yellow
        foreach ($appName in $config.debloatedApps) {
            if (-not [string]::IsNullOrEmpty($appName)) {
                Write-Host "  Removing app: $appName" -ForegroundColor.Gray
                Remove-WinDebloatAPPX -Name $appName
            }
        }
    }

    # Install apps
    if ($config.PSObject.Properties.Name -contains 'installedApps' -and $config.installedApps) {
        Write-Host "Installing applications..." -ForegroundColor.Yellow
        
        # Install winget packages
        if ($config.installedApps.PSObject.Properties.Name -contains 'winget') {
            foreach ($packageId in $config.installedApps.winget) {
                Write-Host "  Installing winget package: $packageId" -ForegroundColor.Gray
                $matchingProgram = Invoke-APPX | Where-Object { $_.Winget -eq $packageId }
                if ($matchingProgram -ne $null) {
                    Invoke-ManageInstall -PackageManger "winget" -manage "Installing" -program $matchingProgram -PackageName $packageId
                }
            }
        }

        # Install choco packages
        if ($config.installedApps.PSObject.Properties.Name -contains 'choco') {
            foreach ($packageId in $config.installedApps.choco) {
                Write-Host "  Installing choco package: $packageId" -ForegroundColor.Gray
                $matchingProgram = Invoke-APPX | Where-Object { $_.Choco -eq $packageId }
                if ($matchingProgram -ne $null) {
                    Invoke-ManageInstall -PackageManger "choco" -manage "Installing" -program $matchingProgram -PackageName $packageId
                }
            }
        }

        # Install pip packages
        if ($config.installedApps.PSObject.Properties.Name -contains 'pip') {
            foreach ($packageName in $config.installedApps.pip) {
                Write-Host "  Installing pip package: $packageName" -ForegroundColor.Gray
                $matchingProgram = Invoke-APPX | Where-Object { $_.PipPackage -eq $packageName }
                if ($matchingProgram -ne $null) {
                    Invoke-ManageInstall -PackageManger "pip" -manage "Installing" -program $matchingProgram -PackageName $packageName
                }
            }
        }
    }

    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Configuration applied successfully!    " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    return $true
}
