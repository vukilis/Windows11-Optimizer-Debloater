function Invoke-normal{
    <#

    .SYNOPSIS
        Set all services to default 
    #>

    #Set-Presets "normal"
    cmd /c services.msc
    Invoke-MessageBox "tweak"
}