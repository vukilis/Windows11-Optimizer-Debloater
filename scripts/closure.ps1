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

$wpf_diskNameInfo.Add_SelectionChanged({Get-DiskInfo})
$wpf_diskName.Add_SelectionChanged({Get-DiskSize})
$wpf_ddlServices.Add_SelectionChanged({Get-Services})

# Check if the window is already opened or not
if ($psform.IsVisible -eq $false -or $psform.IsLoaded -eq $false) {
    $psform.ShowDialog() | Out-Null
} else {
    Write-Host "The window is already open and cannot be shown again."
}

Stop-Transcript

