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

        $result += [PSCustomObject]@{
            Id = $id
            Name = $name
        }
    }

    return $result
}

