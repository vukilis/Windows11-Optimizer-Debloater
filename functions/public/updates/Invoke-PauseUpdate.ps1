function Invoke-PauseUpdate {
    <#

    .SYNOPSIS
        Pause Windows Update up to 35 days or 5 weeks.
    #>

    Write-Host "Pausing Windows Update for 5 weeks..." -ForegroundColor Green

    $pause = (Get-Date).AddDays(35)
    $pause = $pause.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    #Write-Host $pause
    $pause_start = (Get-Date)
    $pause_start = $pause_start.ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" )
    set-itemproperty -path 'hklm:\software\microsoft\windowsupdate\ux\settings' -name 'pauseupdatesexpirytime' -value $pause                                                                                        
    set-itemproperty -path 'hklm:\software\microsoft\windowsupdate\ux\settings' -name 'pausefeatureupdatesstarttime' -value $pause_start
    set-itemproperty -path 'hklm:\software\microsoft\windowsupdate\ux\settings' -name 'pausefeatureupdatesendtime' -value $pause
    set-itemproperty -path 'hklm:\software\microsoft\windowsupdate\ux\settings' -name 'pausequalityupdatesstarttime' -value $pause_start
    set-itemproperty -path 'hklm:\software\microsoft\windowsupdate\ux\settings' -name 'pausequalityupdatesendtime' -value $pause
    set-itemproperty -path 'hklm:\software\microsoft\windowsupdate\ux\settings' -name 'pauseupdatesstarttime' -value $pause_start
    new-item -path 'hklm:\software\policies\microsoft\windows\windowsupdate\au' -force
    new-itemproperty -path  'hklm:\software\policies\microsoft\windows\windowsupdate\au' -name 'noautoupdate' -propertytype dword -value 1  
    
    $pauseDateOnly = (Get-Date).AddDays(35)
    $pauseDateOnly = $pauseDateOnly.ToUniversalTime().ToString("yyyy-MM-dd")

    Art -artN "
======================================
-- Updates paused until $pauseDateOnly --
======================================
" -ch DarkGreen
    Invoke-MessageBox -msg "updatePause" 
}