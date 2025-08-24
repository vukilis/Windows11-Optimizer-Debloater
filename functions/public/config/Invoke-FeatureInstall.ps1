function Invoke-FeatureInstall {
    <#
    .SYNOPSIS
        Applies all selected CheckBox feature dynamically and resets their state.
    #>

    # Loop through all features
    foreach ($featureName in $sync.configs.feature.PSObject.Properties.Name) {
        $tweak = $sync.configs.feature.$featureName
        $apply = $false

        switch ($tweak.Type) {
            "CheckBox" {
                if ($global:FeatureControls.ContainsKey($featureName)) {
                    $apply = [bool]$global:FeatureControls[$featureName].IsChecked
                } elseif ($tweak.DefaultState) {
                    $apply = [bool]$tweak.DefaultState
                }
            }
        }

        if ($apply) {
            if ($tweak.Registry) {
                Write-Host "Applying feature: $($tweak.Content)" -ForegroundColor Green
                foreach ($msg in "DisableMessage","EnableMessage") {
                    if ($tweak.$msg) { Write-Host "InvokeScript:" $tweak.$msg -ForegroundColor Green }
                }
                foreach ($regEntry in $tweak.Registry) {
                    try { 
                        Set-RegistryValue -Path $regEntry.Path -Name $regEntry.Name -Type $regEntry.Type -Value $regEntry.Value 
                    }
                    catch { 
                        Write-Warning "Failed to apply registry tweak: $_" 
                    }
                }
            }

            if ($tweak.InvokeScript) {
                foreach ($msg in "DisableMessage","EnableMessage") {
                    if ($tweak.$msg) { Write-Host "InvokeScript:" $tweak.$msg -ForegroundColor Cyan }
                }
                foreach ($script in $tweak.InvokeScript) {
                    Invoke-Scripts -Name $tweak.Content -Script $script
                    Write-Host "Please Reboot before using." -ForegroundColor Red
                }
            }

            if ($tweak.feature) {
                foreach ($msg in "DisableMessage","EnableMessage") {
                    Write-Host "Applying feature: $($tweak.Content)" -ForegroundColor Green
                    if ($tweak.$msg) { Write-Host "InvokeScript:" $tweak.$msg -ForegroundColor Green }
                }
                foreach ($ft in $tweak.feature) {
                    try {
                        Enable-WindowsOptionalFeature -Online -FeatureName $ft -All -NoRestart
                        Write-Host "Please Reboot before using." -ForegroundColor Red
                    } catch {
                        Write-Warning "Unable to Install $ft due to unhandled exception"
                        Write-Warning $_.Exception.StackTrace
                    }
                }
            }
        }
    }
    
    Invoke-MessageBox -msg "feature"
}