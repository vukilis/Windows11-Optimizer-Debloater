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

$wpf_diskNameInfo.Add_SelectionChanged({Get-DiskInfo})
$wpf_diskName.Add_SelectionChanged({Get-DiskSize})
$wpf_ddlServices.Add_SelectionChanged({Get-Services})
$psform.ShowDialog() | out-null
Stop-Transcript