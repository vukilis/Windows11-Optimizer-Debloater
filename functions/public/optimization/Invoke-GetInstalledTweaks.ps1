function Invoke-GetInstalledTweaks {
    <#
    .SYNOPSIS
        Checks all tweaks that were previously applied by checking actual system state (registry, scheduled tasks, services).
    #>

    $checkedCount = 0
    $skippedCount = 0

    foreach ($toggleName in $sync.configs.tweaks.PSObject.Properties.Name) {
        $tweak = $sync.configs.tweaks.$toggleName
        $isApplied = $false

        # Check registry tweaks
        if ($tweak.PSObject.Properties.Name -contains 'registry' -and $tweak.registry) {
            $registryEntries = @($tweak.registry)
            foreach ($regEntry in $registryEntries) {
                try {
                    if (Test-Path $regEntry.Path) {
                        $regValue = Get-ItemProperty -Path $regEntry.Path -Name $regEntry.Name -ErrorAction SilentlyContinue
                        if ($null -ne $regValue) {
                            $currentValue = $regValue.($regEntry.Name)
                            if ($currentValue -eq $regEntry.Value) {
                                $isApplied = $true
                                break
                            }
                        }
                    }
                } catch {
                    # Skip registry read errors
                }
            }
        }

        # Check scheduled task tweaks
        if (-not $isApplied -and $tweak.PSObject.Properties.Name -contains 'ScheduledTask' -and $tweak.ScheduledTask) {
            $allTasksMatch = $true
            foreach ($task in $tweak.ScheduledTask) {
                try {
                    $scheduledTask = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
                    if ($scheduledTask -and $scheduledTask.State -ne $task.State) {
                        $allTasksMatch = $false
                        break
                    }
                } catch {
                    $allTasksMatch = $false
                    break
                }
            }
            if ($allTasksMatch) {
                $isApplied = $true
            }
        }

        # Check service tweaks
        if (-not $isApplied -and $tweak.PSObject.Properties.Name -contains 'service' -and $tweak.service) {
            $allServicesMatch = $true
            foreach ($service in $tweak.service) {
                try {
                    $svc = Get-Service -Name $service.Name -ErrorAction SilentlyContinue
                    if ($svc -and $svc.StartType -ne $service.StartupType) {
                        $allServicesMatch = $false
                        break
                    }
                } catch {
                    $allServicesMatch = $false
                    break
                }
            }
            if ($allServicesMatch) {
                $isApplied = $true
            }
        }

        # Update checkbox state
        $controlVar = Get-Variable -Name "wpf_$toggleName" -ErrorAction SilentlyContinue
        if ($controlVar -and $controlVar.Value -is [System.Windows.Controls.CheckBox]) {
            $controlVar.Value.IsChecked = $isApplied
            if ($isApplied) {
                # Write-Host "Checked: $toggleName" -ForegroundColor Green
                $checkedCount++
            } else {
                $skippedCount++
            }
        } else {
            $skippedCount++
        }
    }

    Write-Host "$checkedCount installed tweaks loaded, $skippedCount skipped." -ForegroundColor Cyan
    Invoke-MessageBox -msg "tweak"
}
