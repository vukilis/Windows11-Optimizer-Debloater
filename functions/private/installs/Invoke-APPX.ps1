function Invoke-APPX {
    #$jsonfile = Get-Content ./config/applications.json | ConvertFrom-Json
    $result = @()

    foreach ($program in $programs) {
        $program = $program | ConvertFrom-Json
        $id = $program.id
        $name = $program.name
        $winget = $program.winget
        $idPython = $id -like "DblPython*"
        $pipPackage = $program.pip
        $idChoco = $id -like "DblChoco*"
        $choco = $program.choco

        $checkBox = $psform.FindName("$id")
        $isChecked = $checkBox.IsChecked

        $result += [PSCustomObject]@{
            Id = $id
            Name = $name
            Winget = $winget
            IdPython = $idPython
            PipPackage = $pipPackage
            IdChoco = $idChoco
            Choco = $choco
            IsChecked = $isChecked
        }
    }

    return $result
}