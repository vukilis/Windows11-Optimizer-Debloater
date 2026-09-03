function Invoke-ExportConfig {
    <#
    .SYNOPSIS
        Exports current configuration to a JSON file.
    #>

    $config = @{}

    # Export checked apps
    $installApps = @{}
    if ($wpf_PkgMgrWinget.IsChecked) {
        $packageManager = "winget"
    } elseif ($wpf_PkgMgrChoco.IsChecked) {
        $packageManager = "choco"
    } else {
        $packageManager = "winget"
    }
    foreach ($appId in $script:DynamicAppCheckBoxes.Keys) {
        $checkBox = $script:DynamicAppCheckBoxes[$appId]
        if ($checkBox -and $checkBox.IsChecked) {
            $installApps[$appId] = $true
        }
    }
    $config.packageManager = $packageManager
    $config.installApps = $installApps

    # Export checked tweaks
    $config.tweaks = @{}
    foreach ($toggleName in $sync.configs.tweaks.PSObject.Properties.Name) {
        $tweak = $sync.configs.tweaks.$toggleName
        $controlVar = Get-Variable -Name "wpf_$toggleName" -ErrorAction SilentlyContinue
        if ($controlVar -and $controlVar.Value -is [System.Windows.Controls.CheckBox]) {
            if ($controlVar.Value.IsChecked) {
                $config.tweaks[$toggleName] = $true
            }
        }
    }

    # Export DNS settings
    if ($wpf_ddlDNS.SelectedItem) {
        $config.dns = @{
            provider = $wpf_ddlDNS.SelectedItem.Content
        }
    }

    # Export update mode
    if ($wpf_Updatesdefault.IsChecked) { $config.updates = @{ mode = "default" } }
    elseif ($wpf_PauseUpdate.IsChecked) { $config.updates = @{ mode = "pause" } }
    elseif ($wpf_FixesUpdate.IsChecked) { $config.updates = @{ mode = "fixes" } }
    elseif ($wpf_Updatesdisable.IsChecked) { $config.updates = @{ mode = "disable" } }
    elseif ($wpf_Updatessecurity.IsChecked) { $config.updates = @{ mode = "security" } }

    # Export features
    $config.features = @{}
    foreach ($featureName in $sync.configs.feature.PSObject.Properties.Name) {
        $feature = $sync.configs.feature.$featureName
        if ($global:FeatureControls.ContainsKey($featureName)) {
            if ($global:FeatureControls[$featureName].IsChecked) {
                $config.features[$featureName] = $true
            }
        }
    }

    # Export Debloated Apps
    $config.debloatedApps = @()
    $DblSelectPanel = $psform.FindName("SetDebloat")
    if ($DblSelectPanel -and $DblSelectPanel.Children.Count -gt 0) {
        foreach ($child in $DblSelectPanel.Children) {
            if ($child -is [Windows.Controls.Label]) {
                $appName = $child.Content
                if (-not [string]::IsNullOrEmpty($appName)) {
                    $config.debloatedApps += $appName
                }
            }
        }
    }

    # Save to file
    $saveFileDialog = New-Object Microsoft.Win32.SaveFileDialog
    $saveFileDialog.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"
    $saveFileDialog.FileName = "config.json"
    $saveFileDialog.DefaultExt = "json"
    
    if ($saveFileDialog.ShowDialog() -eq $true) {
        $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $saveFileDialog.FileName -Encoding UTF8
        Write-Host "Configuration exported to: $($saveFileDialog.FileName)" -ForegroundColor Green
        Invoke-MessageBox -msg "tweak"
    }
}
