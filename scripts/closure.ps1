$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -eq 7 -and $psVersion.Minor -ge 1) {
    Write-Host "You are running PowerShell version 7.1 or higher."
    Get-Author7
} elseif ($psVersion.Major -eq 5 -and $psVersion.Minor -eq 1) {
    Write-Host "You are running PowerShell version 5.1."
    Get-Author5
} else {
    Write-Host "You are running a different version of PowerShell."
}
$wpf_diskNameInfo.Add_SelectionChanged({Get-DiskInfo})
$wpf_diskName.Add_SelectionChanged({Get-DiskSize})
$wpf_ddlServices.Add_SelectionChanged({Get-Services})
$psform.ShowDialog() | out-null
Stop-Transcript