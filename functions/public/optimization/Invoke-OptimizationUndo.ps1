function Invoke-OptimizationUndo {
    <#
    .SYNOPSIS
        Undo all selected CheckBox tweaks dynamically and resets their state.
    #>

    # Loop through all tweaks
    foreach ($toggleName in $sync.configs.tweaks.PSObject.Properties.Name) {
        $tweak = $sync.configs.tweaks.$toggleName

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
            "UndoScript" {
                $apply = $true
            }
        }

        # Apply registry changes if available and checkbox is checked
        if ($apply) {
            if ($tweak.ScheduledTask) {
                Write-Host "ScheduledTask: Revert the $($tweak.Content) to the default settings!" $tweak.message -ForegroundColor Yellow
                foreach ($task in $tweak.ScheduledTask) {
                    try {
                        Set-ScheduledTask -Name $task.Name -State $task.OriginalState
                    } catch {
                        Write-Warning "Failed to set scheduled task '$($task.Name)' to $($task.OriginalState): $_"
                    }
                }
            }

            if ($tweak.Registry) {
                Write-Host "Registry: Revert the $($tweak.Content) to the default settings!" -ForegroundColor Green
                foreach ($regEntry in $tweak.Registry) {
                    try { 
                        Set-RegistryValue -Path $regEntry.Path -Name $regEntry.Name -Type $regEntry.Type -Value $regEntry.OriginalValue }
                    catch { 
                        Write-Warning "Failed to apply registry tweak: $_" }
                }
            }
            if ($tweak.UndoScript) {
                # Write-Host "UndoScript:" $tweak.DisableMessage -ForegroundColor Cyan
                Write-Host "UndoScript: Revert the $($tweak.Content) to the default settings!" -ForegroundColor Cyan
                foreach ($script in $tweak.UndoScript) {
                    Invoke-Scripts -Name $tweak.Content -Script $script
                }
            }
            if ($tweak.service) {
                Write-Host "Service: Revert the $($tweak.Content) to the default settings!" $tweak.message -ForegroundColor Magenta
                foreach ($service in $tweak.service) {
                    try {
                        Set-WinService -Name $service.Name -StartupType $service.OriginalType
                    } catch {
                        Write-Warning "Failed to set service '$($service.Name)' to $($service.OriginalType): $_"
                    }
                }
            }
        }

    }

    Invoke-MessageBox -msg "undotweak"
}