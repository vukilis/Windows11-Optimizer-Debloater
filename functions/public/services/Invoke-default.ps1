function Invoke-default{
    <#

    .SYNOPSIS
        Set all services to their Windows default startup types
    #>

    $services_manual = @(
        "ALG"
        "AJRouter"
        "BcastDVRUserService_48486de"
        "BthAvctpSvc"
        "CaptureService_48486de"
        "cbdhsvc_48486de"
        "diagnosticshub.standardcollector.service"
        "dmwappushservice"
        "Fax"
        "fhsvc"
        "FontCache"
        "lfsvc"
        "lmhosts"
        "MapsBroker"
        "MicrosoftEdgeElevationService"
        "MSDTC"
        "NetTcpPortSharing"
        "PcaSvc"
        "PerfHost"
        "PhoneSvc"
        "PrintNotify"
        "QWAVE"
        "RemoteAccess"
        "RemoteRegistry"
        "RetailDemo"
        "RtkBtManServ"
        "SCardSvr"
        "seclogon"
        "SEMgrSvc"
        "SharedAccess"
        "ssh-agent"
        "stisvc"
        "WerSvc"
        "wisvc"
        "WMPNetworkSvc"
        "WpcMonSvc"
        "WPDBusEnum"
        "XblAuthManager"
        "XblGameSave"
        "XboxNetApiSvc"
        "XboxGipSvc"
        "AppVClient"
        "CertPropSvc"
        "DialogBlockingService"
        "MsKeyboardFilter"
        "shpamsvc"
        "ScDeviceEnum"
        "UevAgentService"
        "icssvc"
        "vmicguestinterface"
        "vmicheartbeat"
        "vmickvpexchange"
        "vmicrdv"
        "vmicshutdown"
        "vmictimesync"
        "vmicvmsession"
        "HPAppHelperCap"
        "HPDiagsCap"
        "HPNetworkCap"
        "HPSysInfoCap"
        "HpTouchpointAnalyticsService"
        "wsearch"
    )

    foreach ($service in $services_manual) {
        Write-Host "Setting $service StartupType to Manual" -ForegroundColor Yellow
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
    }

    $services_automatic = @(
        "Browser"
        "DiagTrack"
        "DPS"
        "edgeupdate"
        "edgeupdatem"
        "gupdate"
        "gupdatem"
        "NahimicService"
        "SysMain"
        "TrkWks"
        "WpnService"
        "WSearch"
        "DusmSvc"
        "uhssvc"
        "NcbService"
        "SCPolicySvc"
        "Spooler"
        "iphlpsvc"
        "WbioSrvc"
        "tzautoupdate"
        "HvHost"
        "HPAppHelperCap"
        "HPDiagsCap"
        "HPNetworkCap"
        "HPSysInfoCap"
        "HpTouchpointAnalyticsService"
    )

    foreach ($service in $services_automatic) {
        Write-Host "Setting $service StartupType to Automatic" -ForegroundColor Yellow
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic -ErrorAction SilentlyContinue
    }
    Art -artN "
=============================
--- Services set to Default ---
=============================
" -ch Cyan
    Invoke-MessageBox "tweak"
}
