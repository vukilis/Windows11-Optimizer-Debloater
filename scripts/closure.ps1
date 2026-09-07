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

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "################################################################################################" -ForegroundColor Red
    Write-Host "Not running as administrator. Please run the script as an administrator!" -ForegroundColor Red
    Write-Host "If you continue to use as non-admin user, it will result to script creates unexpected behaviour!" -ForegroundColor Red
    Write-Host "################################################################################################" -ForegroundColor Red

    $wpf_ElevatorStatus.Visibility = "Visible"
    $wpf_ElevatorStatus.Background = "red"
    $wpf_ElevatorMode.Content = "Not running as administrator. Please run the script as an administrator!!!"
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

function Update-SelectedAppsCount {
    $count = 0
    foreach ($cb in $script:DynamicAppCheckBoxes.Values) {
        if ($cb.IsChecked -eq $true) {
            $count++
        }
    }
    if ($wpf_SelectedAppsCount) {
        $wpf_SelectedAppsCount.Content = $count.ToString()
    }
}

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
    $cbox.Margin = New-Object System.Windows.Thickness(4)
    $cbox.FontSize = 11
    $cbox.FontFamily = New-Object System.Windows.Media.FontFamily("Gadugi")
    $cbox.tooltip = $program.description

    $scaleTransform = New-Object System.Windows.Media.ScaleTransform
    $scaleTransform.ScaleX = 1.5
    $scaleTransform.ScaleY = 1.5
    $cbox.LayoutTransform = $scaleTransform

    $cbox.Add_Checked({ Update-SelectedAppsCount })
    $cbox.Add_Unchecked({ Update-SelectedAppsCount })

    $panel.Children.Add($cbox) | Out-Null
    $script:DynamicAppCheckBoxes[$program.id] = $cbox
    $script:DynamicAppChocoSupport[$program.id] = ($program.choco -ne $null -and $program.choco -ne '')
}

# Category toggle handlers
$categoryToggleMap = @{
    "Development"        = @{ Header = $wpf_HeaderDevelopment;        Arrow = $wpf_ArrowDevelopment;        Panel = $wpf_CategoryDevelopmentPanel }
    "Microsoft Tools"    = @{ Header = $wpf_HeaderMicrosoftTools;    Arrow = $wpf_ArrowMicrosoftTools;    Panel = $wpf_CategoryMicrosoftToolsPanel }
    "Browsers"           = @{ Header = $wpf_HeaderBrowsers;           Arrow = $wpf_ArrowBrowsers;           Panel = $wpf_CategoryBrowsersPanel }
    "Communications"     = @{ Header = $wpf_HeaderCommunications;     Arrow = $wpf_ArrowCommunications;     Panel = $wpf_CategoryCommunicationsPanel }
    "Gaming Launchers"   = @{ Header = $wpf_HeaderGamingLaunchers;   Arrow = $wpf_ArrowGamingLaunchers;   Panel = $wpf_CategoryGamingLaunchersPanel }
    "Pro Tools"          = @{ Header = $wpf_HeaderProTools;          Arrow = $wpf_ArrowProTools;          Panel = $wpf_CategoryProToolsPanel }
    "Document"           = @{ Header = $wpf_HeaderDocument;           Arrow = $wpf_ArrowDocument;           Panel = $wpf_CategoryDocumentPanel }
    "Multimedia Tools"   = @{ Header = $wpf_HeaderMultimediaTools;   Arrow = $wpf_ArrowMultimediaTools;   Panel = $wpf_CategoryMultimediaToolsPanel }
    "Selfhosted Tools"   = @{ Header = $wpf_HeaderSelfhosted;       Arrow = $wpf_ArrowSelfhosted;       Panel = $wpf_CategorySelfhostedPanel }
    "Utilities"          = @{ Header = $wpf_HeaderUtilities;          Arrow = $wpf_ArrowUtilities;          Panel = $wpf_CategoryUtilitiesPanel }
}

foreach ($cat in $categoryToggleMap.Keys) {
    $header = $categoryToggleMap[$cat].Header
    $arrow = $categoryToggleMap[$cat].Arrow
    $panel = $categoryToggleMap[$cat].Panel
    
    $handler = {
        if ($panel.Visibility -eq [System.Windows.Visibility]::Visible) {
            $panel.Visibility = [System.Windows.Visibility]::Collapsed
            $arrow.RenderTransform = [System.Windows.Media.RotateTransform]::new(180)
        } else {
            $panel.Visibility = [System.Windows.Visibility]::Visible
            $arrow.RenderTransform = [System.Windows.Media.RotateTransform]::new(0)
        }
    }.GetNewClosure()
    
    $header.Add_MouseLeftButtonUp($handler)
}

$categoryHeaders = @{
    "Development"        = $wpf_HeaderDevelopment
    "Microsoft Tools"    = $wpf_HeaderMicrosoftTools
    "Browsers"           = $wpf_HeaderBrowsers
    "Communications"     = $wpf_HeaderCommunications
    "Gaming Launchers"   = $wpf_HeaderGamingLaunchers
    "Pro Tools"          = $wpf_HeaderProTools
    "Document"           = $wpf_HeaderDocument
    "Multimedia Tools"   = $wpf_HeaderMultimediaTools
    "Selfhosted Tools"   = $wpf_HeaderSelfhosted
    "Utilities"          = $wpf_HeaderUtilities
}

$categoryFilterMap = @{
    "All"                = $wpf_CategoryFilterAll
    "Development"        = $wpf_CategoryFilterDevelopment
    "Microsoft Tools"    = $wpf_CategoryFilterMicrosoftTools
    "Browsers"           = $wpf_CategoryFilterBrowsers
    "Communications"     = $wpf_CategoryFilterCommunications
    "Gaming Launchers"   = $wpf_CategoryFilterGamingLaunchers
    "Pro Tools"          = $wpf_CategoryFilterProTools
    "Document"           = $wpf_CategoryFilterDocument
    "Multimedia Tools"   = $wpf_CategoryFilterMultimediaTools
    "Selfhosted Tools"   = $wpf_CategoryFilterSelfhosted
    "Utilities"          = $wpf_CategoryFilterUtilities
}

$script:isUpdating = $false

foreach ($filter in $categoryFilterMap.Keys) {
    $btn = $categoryFilterMap[$filter]

    $handler = {
        param($sender, $e)

        if ($script:isUpdating) { return }
        $script:isUpdating = $true

        try {
            if ($sender.IsChecked) {
                if ($filter -eq "All") {
                    foreach ($otherKey in $categoryFilterMap.Keys) {
                        if ($otherKey -ne "All") {
                            $categoryFilterMap[$otherKey].IsChecked = $false
                        }
                    }
                } else {
                    $categoryFilterMap["All"].IsChecked = $false
                    foreach ($otherKey in $categoryFilterMap.Keys) {
                        if ($otherKey -ne $filter -and $otherKey -ne "All") {
                            $categoryFilterMap[$otherKey].IsChecked = $false
                        }
                    }
                }
            } else {
                $anyChecked = $false
                foreach ($key in $categoryFilterMap.Keys) {
                    if ($categoryFilterMap[$key].IsChecked) {
                        $anyChecked = $true
                        break
                    }
                }
                if (-not $anyChecked) {
                    $categoryFilterMap["All"].IsChecked = $true
                }
            }

            $allIsChecked = $categoryFilterMap["All"].IsChecked
            foreach ($cat in $categoryPanels.Keys) {
                if ($allIsChecked -or ($categoryFilterMap.ContainsKey($cat) -and $categoryFilterMap[$cat].IsChecked)) {
                    $categoryPanels[$cat].Visibility = [System.Windows.Visibility]::Visible
                    $categoryHeaders[$cat].Visibility = [System.Windows.Visibility]::Visible
                } else {
                    $categoryPanels[$cat].Visibility = [System.Windows.Visibility]::Collapsed
                    $categoryHeaders[$cat].Visibility = [System.Windows.Visibility]::Collapsed
                }
            }
        }
        finally {
            $script:isUpdating = $false
        }
    }.GetNewClosure()

    $btn.Add_Checked($handler)
    $btn.Add_Unchecked($handler)
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

