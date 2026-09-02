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
$wpf_ddlServices.Add_SelectionChanged({Get-Services})

# Assign tooltips after the window is fully loaded so FindName sees all controls
$psform.Add_Loaded({
    Invoke-SetDynamicToolTip
})

# Check if the window is already opened or not
if ($psform.IsVisible -eq $false -or $psform.IsLoaded -eq $false) {
    $psform.ShowDialog() | Out-Null
} else {
    Write-Host "The window is already open and cannot be shown again."
}

Stop-Transcript

