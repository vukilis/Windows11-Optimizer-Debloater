function Invoke-FixesSound {
    <#

    .SYNOPSIS
        Reset sound service. 
    #>

    Restart-Service -Name "Audiosrv" -Force -Confirm:$false
    Write-Host "Windows Audio Service restarted successfully."
    Art -artN "
==================================================
-- Windows Audio Service restarted successfully --
==================================================
" -ch DarkGreen
    Invoke-MessageBox -msg "soundReset"
}