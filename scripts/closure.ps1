$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -eq 7 -and $psVersion.Minor -ge 1) {
    Write-Host "You are running PowerShell version 7.1 or higher." -ForegroundColor Green
    Get-Author7
} elseif ($psVersion.Major -eq 5 -and $psVersion.Minor -eq 1) {
    Write-Host "You are running PowerShell version 5.1." -ForegroundColor Blue
    Get-Author5
} else {
    Write-Host "You are running a different version of PowerShell. Versions from 1.0 to 5.0 not supported!" -ForegroundColor Red
}

# If -Config is provided, apply config and exit without GUI
if ($Config) {
    $script:HeadlessMode = $true
    $result = Invoke-ApplyConfigFile -ConfigPath $Config
    if ($result) {
        Write-Host "`nHeadless mode completed. The terminal will remain open. You can close it manually when ready." -ForegroundColor Cyan
    } else {
        Write-Host "`nHeadless mode failed. Check the errors above." -ForegroundColor Red
    }
    return
}

$wpf_diskNameInfo.Add_SelectionChanged({Get-DiskInfo})
$wpf_diskName.Add_SelectionChanged({Get-DiskSize})

# Assign tooltips after the window is fully loaded so FindName sees all controls
$psform.Add_Loaded({
    Invoke-SetDynamicToolTip
})

# Dynamically populate INSTALL tab app checkboxes from $programs
$script:DynamicAppCheckBoxes = @{}
$script:DynamicAppChocoSupport = @{}
$script:SelectedPackageManager = "winget"

$categoryPanels = @{
    "Development"        = $wpf_CategoryDevelopmentPanel
    "Microsoft Tools"    = $wpf_CategoryMicrosoftToolsPanel
    "Browsers"           = $wpf_CategoryBrowsersPanel
    "Communications"     = $wpf_CategoryCommunicationsPanel
    "Gaming Launchers"   = $wpf_CategoryGamingLaunchersPanel
    "Pro Tools"          = $wpf_CategoryProToolsPanel
    "Document"           = $wpf_CategoryDocumentPanel
    "Multimedia Tools"   = $wpf_CategoryMultimediaToolsPanel
    "Selfhosted Tools"   = $wpf_CategorySelfhostedPanel
    "Utilities"          = $wpf_CategoryUtilitiesPanel
}

foreach ($program in $programs) {
    $program = $program | ConvertFrom-Json
    $category = $program.category
    if (-not $category -or -not $categoryPanels.ContainsKey($category)) {
        continue
    }

    $panel = $categoryPanels[$category]
    if (-not $panel) {
        continue
    }

    $cbox = New-Object System.Windows.Controls.CheckBox
    $cbox.Name = $program.id
    $cbox.Content = $program.content
    $cbox.Foreground = "#a69f6c"
    $cbox.HorizontalAlignment = "Left"
    $cbox.Width = "auto"
    $cbox.Cursor = [System.Windows.Input.Cursors]::Hand
    $cbox.Margin = New-Object System.Windows.Thickness(8, 5, 8, 5)
    $cbox.FontSize = 11
    $cbox.FontFamily = New-Object System.Windows.Media.FontFamily("Gadugi")
    $cbox.tooltip = $program.description

    $scaleTransform = New-Object System.Windows.Media.ScaleTransform
    $scaleTransform.ScaleX = 1.5
    $scaleTransform.ScaleY = 1.5
    $cbox.LayoutTransform = $scaleTransform

    $panel.Children.Add($cbox) | Out-Null
    $script:DynamicAppCheckBoxes[$program.id] = $cbox
    $script:DynamicAppChocoSupport[$program.id] = ($program.choco -ne $null -and $program.choco -ne '')
}

$wpf_PkgMgrWinget.Add_Checked({
    $script:SelectedPackageManager = "winget"
    foreach ($program in $programs) {
        $program = $program | ConvertFrom-Json
        if ($script:DynamicAppCheckBoxes.ContainsKey($program.id)) {
            $script:DynamicAppCheckBoxes[$program.id].IsEnabled = $true
            $script:DynamicAppCheckBoxes[$program.id].Foreground = "#a69f6c"
        }
    }
})

$wpf_PkgMgrChoco.Add_Checked({
    $script:SelectedPackageManager = "choco"
    foreach ($program in $programs) {
        $program = $program | ConvertFrom-Json
        if ($script:DynamicAppCheckBoxes.ContainsKey($program.id)) {
            $hasChoco = $script:DynamicAppChocoSupport[$program.id]
            $script:DynamicAppCheckBoxes[$program.id].IsEnabled = $hasChoco
            if (-not $hasChoco) {
                $script:DynamicAppCheckBoxes[$program.id].IsChecked = $false
                $script:DynamicAppCheckBoxes[$program.id].Foreground = "#5a5a5a"
            } else {
                $script:DynamicAppCheckBoxes[$program.id].Foreground = "#a69f6c"
            }
        }
    }
})

# Check if the window is already opened or not
if ($psform.IsVisible -eq $false -or $psform.IsLoaded -eq $false) {
    $psform.ShowDialog() | Out-Null
} else {
    Write-Host "The window is already open and cannot be shown again."
}

Stop-Transcript

