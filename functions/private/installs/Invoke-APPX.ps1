function Invoke-APPX {
    #$jsonfile = Get-Content ./config/applications.json | ConvertFrom-Json
    $result = @()

    foreach ($program in $programs) {
        $program = $program | ConvertFrom-Json
        $id = $program.id
        $name = $program.content
        $winget = $program.winget
        $choco = $program.choco
        $description = $program.description

        $checkBox = $psform.FindName("$id")
        if (-not $checkBox -and $script:DynamicAppCheckBoxes.ContainsKey($id)) {
            $checkBox = $script:DynamicAppCheckBoxes[$id]
        }
        if ($checkBox) {
            $isChecked = $checkBox.IsChecked
        } else {
            $isChecked = $false
        }

        $result += [PSCustomObject]@{
            Id = $id
            Name = $name
            Winget = $winget
            Choco = $choco
            description = $description
            IsChecked = $isChecked
        }
    }

    return $result
}

