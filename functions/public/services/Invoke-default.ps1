function Invoke-default{
    <#

    .SYNOPSIS
        Set all services to their Windows default startup types
    #>

    Invoke-ServicePreset -Mode "default"
}
