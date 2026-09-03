function Invoke-ImportConfig {
    <#
    .SYNOPSIS
        Imports configuration from a JSON file and applies it to the UI.
    #>

    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"
    $openFileDialog.FileName = "config.json"
    $openFileDialog.DefaultExt = "json"

    if ($openFileDialog.ShowDialog() -ne $true) {
        return
    }

    $configPath = $openFileDialog.FileName

    try {
        $config = Get-Content -Path $configPath -Raw -ErrorAction Stop | ConvertFrom-Json
    } catch {
        Write-Warning "Failed to parse config file: $_"
        Invoke-MessageBox -msg "error"
        return
    }

    Write-Host "Importing configuration from: $configPath" -ForegroundColor Cyan

    # Reset all apps
    foreach ($appId in $script:DynamicAppCheckBoxes.Keys) {
        $script:DynamicAppCheckBoxes[$appId].IsChecked = $false
    }

    # Reset all tweaks
    foreach ($toggleName in $sync.configs.tweaks.PSObject.Properties.Name) {
        $controlVar = Get-Variable -Name "wpf_$toggleName" -ErrorAction SilentlyContinue
        if ($controlVar -and $controlVar.Value -is [System.Windows.Controls.CheckBox]) {
            $controlVar.Value.IsChecked = $false
        }
    }

    # Reset all features
    foreach ($featureControl in $global:FeatureControls.Values) {
        $featureControl.IsChecked = $false
    }

    # Import package manager
    if ($config.PSObject.Properties.Name -contains 'packageManager') {
        if ($config.packageManager -eq "choco") {
            $wpf_PkgMgrChoco.IsChecked = $true
            $wpf_PkgMgrWinget.IsChecked = $false
        } else {
            $wpf_PkgMgrWinget.IsChecked = $true
            $wpf_PkgMgrChoco.IsChecked = $false
        }
    }

    # Import install apps
    if ($config.PSObject.Properties.Name -contains 'installApps' -and $config.installApps) {
        foreach ($appId in $config.installApps.PSObject.Properties.Name) {
            if ($config.installApps.$appId -eq $true) {
                $checkBox = $script:DynamicAppCheckBoxes[$appId]
                if ($checkBox) {
                    $checkBox.IsChecked = $true
                }
            }
        }
    }

    # Import tweaks
    if ($config.PSObject.Properties.Name -contains 'tweaks' -and $config.tweaks) {
        foreach ($toggleName in $config.tweaks.PSObject.Properties.Name) {
            if ($config.tweaks.$toggleName -eq $true) {
                $controlVar = Get-Variable -Name "wpf_$toggleName" -ErrorAction SilentlyContinue
                if ($controlVar -and $controlVar.Value -is [System.Windows.Controls.CheckBox]) {
                    $controlVar.Value.IsChecked = $true
                }
            }
        }
    }

    # Import DNS settings
    if ($config.PSObject.Properties.Name -contains 'dns' -and $config.dns) {
        if ($config.dns.provider) {
            foreach ($item in $wpf_ddlDNS.Items) {
                if ($item.Content -eq $config.dns.provider) {
                    $wpf_ddlDNS.SelectedItem = $item
                    break
                }
            }
        }
    }

    # Import update mode
    if ($config.PSObject.Properties.Name -contains 'updates' -and $config.updates) {
        $mode = $config.updates.mode
        switch ($mode) {
            "default" { $wpf_Updatesdefault.IsChecked = $true }
            "pause"   { $wpf_PauseUpdate.IsChecked = $true }
            "fixes"   { $wpf_FixesUpdate.IsChecked = $true }
            "disable" { $wpf_Updatesdisable.IsChecked = $true }
            "security" { $wpf_Updatessecurity.IsChecked = $true }
        }
    }

    # Import features
    if ($config.PSObject.Properties.Name -contains 'features' -and $config.features) {
        foreach ($featureName in $config.features.PSObject.Properties.Name) {
            if ($config.features.$featureName -eq $true) {
                if ($global:FeatureControls.ContainsKey($featureName)) {
                    $global:FeatureControls[$featureName].IsChecked = $true
                }
            }
        }
    }

    # Import debloated apps
    if ($config.PSObject.Properties.Name -contains 'debloatedApps' -and $config.debloatedApps) {
        $DblSelectPanel = $psform.FindName("SetDebloat")
        $DblGetPanel = $psform.FindName("GetDebloat")
        if ($DblSelectPanel -and $DblGetPanel) {
            $DblSelectPanel.Children.Clear()
            foreach ($appName in $config.debloatedApps) {
                if (-not [string]::IsNullOrEmpty($appName)) {
                    AddCustomLabel -content $appName -panel $DblSelectPanel -Foreground "#a69f6c" -Margin @(15, 5, 15, 4) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
                    foreach ($child in $DblGetPanel.Children) {
                        if ($child -is [System.Windows.Controls.CheckBox] -and $child.Content -eq $appName) {
                            $child.IsChecked = $true
                            break
                        }
                    }
                }
            }
        }
    }

    Write-Host "Configuration imported successfully!" -ForegroundColor Green
    Invoke-MessageBox -msg "tweak"
}
