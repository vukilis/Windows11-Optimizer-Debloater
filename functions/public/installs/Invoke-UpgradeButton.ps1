function Invoke-UpgradeButton {
    <#

    .SYNOPSIS
        This function upgrade all selected apps
    #>

    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $checkBox = $psform.FindName($program.Id)
        $isChecked = $checkBox.IsChecked

        if ($isChecked -eq $true -and $program.IdPython) {
            Invoke-ManageInstall -PackageManger "pip" -manage "Upgrading" -program $name -PackageName $program.PipPackage
        }elseif ($isChecked -eq $true -and $program.IdChoco){
            Invoke-ManageInstall -PackageManger "choco" -manage "Upgrading" -program $name -PackageName $program.Choco
        }elseif ($isChecked -eq $true){
            Invoke-ManageInstall -PackageManger "winget" -manage "Upgrading" -program $name -PackageName $program.Winget
        }else {
            continue
        }
    }
    
    Invoke-MessageBox -msg "upgrade"
}