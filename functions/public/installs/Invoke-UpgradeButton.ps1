function Invoke-UpgradeButton {
    <#

    .SYNOPSIS
        This function upgrade all selected apps
    #>

    $matchingProgram = Invoke-APPX
    $packageManager = $script:SelectedPackageManager
    foreach ($program in $matchingProgram) {
        $checkBox = $psform.FindName($program.Id)
        if (-not $checkBox -and $script:DynamicAppCheckBoxes.ContainsKey($program.Id)) {
            $checkBox = $script:DynamicAppCheckBoxes[$program.Id]
        }
        $isChecked = $checkBox.IsChecked
        $isEnabled = $checkBox.IsEnabled

        if ($isChecked -eq $true -and $isEnabled -eq $true) {
            if ($packageManager -eq "choco" -and $program.Choco -ne $null -and $program.Choco -ne '') {
                Invoke-ManageInstall -PackageManger "choco" -manage "Upgrading" -program $program.Name -PackageName $program.Choco
            }
            elseif ($program.Winget) {
                Invoke-ManageInstall -PackageManger "winget" -manage "Upgrading" -program $program.Name -PackageName $program.Winget
            }
        }
    }
    
    Invoke-MessageBox -msg "upgrade"
}

