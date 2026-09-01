function Invoke-recommended{
    <#

    .SYNOPSIS
        Set all services to manual startup 
    #>

    Invoke-ServicePreset -Mode "recommended"
}
