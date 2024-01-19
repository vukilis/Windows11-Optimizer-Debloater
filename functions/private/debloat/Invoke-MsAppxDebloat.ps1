function Invoke-MsAppxDebloat {
    #$jsonfile = Get-Content ./config/msAppxDebloat.json | ConvertFrom-Json
    param(
        $state
    )
    $result = @()
    foreach ($app in $appx) {
        $app = $app | ConvertFrom-Json
        $id = $app.id
        $name = $app.name
        $GetDebloatCheckBox = $app.IsChecked
        $isChecked = $GetDebloatCheckBox

        $result += [PSCustomObject]@{
            Id = $id
            Name = $name
            IsChecked = $isChecked
        }
    }

    return $result
}