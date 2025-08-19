function Invoke-OptimizationButton {
    <#
    .SYNOPSIS
        Applies all selected CheckBox tweaks dynamically and resets their state.
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
            "InvokeScript" {
                $apply = $true
            }
        }

        # Apply registry changes if available and checkbox is checked
        if ($apply) {
            if ($tweak.ScheduledTask) {
                foreach ($msg in "DisableMessage","EnableMessage") {
                    if ($tweak.$msg) { Write-Host "ScheduledTask:" $tweak.$msg -ForegroundColor Yellow }
                }
                foreach ($task in $tweak.ScheduledTask) {
                    try {
                        Set-ScheduledTask -Name $task.Name -State $task.State
                    } catch {
                        Write-Warning "Failed to set scheduled task '$($task.Name)' to $($task.State): $_"
                    }
                }
            }

            if ($tweak.Registry) {
                foreach ($msg in "DisableMessage","EnableMessage") {
                    if ($tweak.$msg) { Write-Host "InvokeScript:" $tweak.$msg -ForegroundColor Green }
                }
                foreach ($regEntry in $tweak.Registry) {
                    try { 
                        Set-RegistryValue -Path $regEntry.Path -Name $regEntry.Name -Type $regEntry.Type -Value $regEntry.Value }
                    catch { 
                        Write-Warning "Failed to apply registry tweak: $_" }
                }
            }
            if ($tweak.InvokeScript) {
                foreach ($msg in "DisableMessage","EnableMessage") {
                    if ($tweak.$msg) { Write-Host "InvokeScript:" $tweak.$msg -ForegroundColor Cyan }
                }
                foreach ($script in $tweak.InvokeScript) {
                    Invoke-Scripts -Name $tweak.Content -Script $script
                }
            }
            if ($tweak.service) {
                foreach ($msg in "DisableMessage","EnableMessage") {
                    if ($tweak.$msg) { Write-Host "Service:" $tweak.$msg -ForegroundColor Magenta }
                }
                foreach ($service in $tweak.service) {
                    try {
                        Set-WinService -Name $service.Name -StartupType $service.StartupType
                    } catch {
                        Write-Warning "Failed to set service '$($service.Name)' to $($service.StartupType): $_"
                    }
                }
            }
        }

    }

    Invoke-MessageBox -msg "tweak"
}