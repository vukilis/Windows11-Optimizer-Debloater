function Invoke-installButton {
    <#

    .SYNOPSIS
        This function install all selected apps
        Support winget, choco and pip packages  
    #>

    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $checkBox = $psform.FindName($program.Id)
        $isChecked = $checkBox.IsChecked

        if ($isChecked -eq $true -and $program.IdPython) {
            Invoke-ManageInstall -PackageManger "pip" -manage "Installing" -program $program.Name -PackageName $program.PipPackage
        }elseif ($isChecked -eq $true -and $program.IdChoco){
            Invoke-ManageInstall -PackageManger "choco" -manage "Installing" -program $program.Name -PackageName $program.Choco
        }elseif ($isChecked -eq $true){
            Invoke-ManageInstall -PackageManger "winget" -manage "Installing" -program $program.Name -PackageName $program.Winget
        }else {
            continue
        }
    }
    
    Invoke-MessageBox -msg "install"
}