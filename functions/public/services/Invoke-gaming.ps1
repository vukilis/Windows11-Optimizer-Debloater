function Invoke-gaming{
    <#

    .SYNOPSIS
        Set all services to gaming mode 
    #>

    # Set-Presets "gaming"
    $services_m = @(
        "BcastDVRUserService_48486de"                  # GameDVR and Broadcast is used for Game Recordings and Live Broadcasts
        "Browser"                                      # Let users browse and locate shared resources in neighboring computers
        "BthAvctpSvc"                                  # AVCTP service (needed for Bluetooth Audio Devices or Wireless Headphones)
        "CaptureService_48486de"                       # Optional screen capture functionality for applications that call the Windows.Graphics.Capture API.
        "cbdhsvc_48486de"                              # Clipboard Service
        "edgeupdate"                                   # Edge Update Service
        "edgeupdatem"                                  # Another Update Service
        "FontCache"                                    # Windows font cache
        "gupdate"                                      # Google Update
        "gupdatem"                                     # Another Google Update Service
        "lmhosts"                                      # TCP/IP NetBIOS Helper
        "MicrosoftEdgeElevationService"                # Another Edge Update Service
        "MSDTC"                                        # Distributed Transaction Coordinator
        "NahimicService"                               # Nahimic Service
        "PerfHost"                                     # Remote users and 64-bit processes to query performance.
        "QWAVE"                                        # Quality Windows Audio Video Experience (audio and video might sound worse)
        "RtkBtManServ"                                 # Realtek Bluetooth Device Manager Service
        "SharedAccess"                                 # Internet Connection Sharing (ICS)
        "ssh-agent"                                    # OpenSSH Authentication Agent
        "TrkWks"                                       # Distributed Link Tracking Client
        "WMPNetworkSvc"                                # Windows Media Player Network Sharing Service
        "WPDBusEnum"                                   # Portable Device Enumerator Service
        "WpnService"                                   # WpnService (Push Notifications may not work)
        "WSearch"                                      # Windows Search
        "XblAuthManager"                               # Xbox Live Auth Manager (Disabling Breaks Xbox Live Games)
        "XblGameSave"                                  # Xbox Live Game Save Service (Disabling Breaks Xbox Live Games)
        "XboxNetApiSvc"                                # Xbox Live Networking Service (Disabling Breaks Xbox Live Games)
        "XboxGipSvc"                                   # Xbox Accessory Management Service
        "HPAppHelperCap"
        "HPDiagsCap"
        "HPNetworkCap"
        "HPSysInfoCap"
        "HpTouchpointAnalyticsService"
        "HvHost"
        "vmicguestinterface"
        "vmicheartbeat"
        "vmickvpexchange"
        "vmicrdv"
        "vmicshutdown"
        "vmictimesync"
        "vmicvmsession"
    )

    foreach ($service in $services_m) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist
        Write-Host "Setting $service StartupType to Manual" -ForegroundColor Yellow
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
    }

    $services_d = @(
        "ALG"                                          # Application Layer Gateway Service(Provides support for 3rd party protocol plug-ins for Internet Connection Sharing)
        "AJRouter"                                     # Needed for AllJoyn Router Service
        "tzautoupdate"                                 # DialogBlockingService
        "CertPropSvc"                                  # Certificate Propagation
        "DusmSvc"                                      # Data Usage
        "DialogBlockingService"                        # DialogBlockingService
        "DiagTrack"                                    # Diagnostics Tracking Service
        "diagnosticshub.standardcollector.service"     # Microsoft (R) Diagnostics Hub Standard Collector Service
        "dmwappushservice"                             # WAP Push Message Routing Service
        "DPS"                                          # Diagnostic Policy Service (Detects and Troubleshoots Potential Problems)
        "Fax"                                          # Fax Service
        "fhsvc"                                        # Fax History
        "AppVClient"                                   # Microsoft App-V Client
        "MapsBroker"                                   # Downloaded Maps Manager
        "MsKeyboardFilter"                             # Microsoft Keyboard Filter
        "uhssvc"                                       # Microsoft Update Health
        "NcbService"                                   # Network Connection Broker (allow Windows Store Apps to receive notifications from the internet)
        "NetTcpPortSharing"                            # Net.Tcp Port Sharing Service
        "PcaSvc"                                       # Program Compatibility Assistant Service
        "PhoneSvc"                                     # Phone Service(Manages the telephony state on the device)
        "PrintNotify"                                  # Windows printer notifications and extentions
        "RemoteRegistry"                               # Remote Registry
        "RemoteAccess"                                 # Routing and Remote Access
        "RetailDemo"                                   # Demo Mode for Store Display
        "shpamsvc"                                     # Shared PC Account Manager
        "ScDeviceEnum"                                 # Smart Card Device Enumeration
        "SCPolicySvc"                                  # Smart Card Removal Policy
        "SEMgrSvc"                                     # Payments and NFC/SE Manager (Manages payments and Near Field Communication (NFC) based secure elements)
        "seclogon"                                     # Secondary Logon (Disables other credentials only password will work)
        "stisvc"                                       # Windows Image Acquisition (WIA)
        "Spooler"                                      # Print Spooler
        "SCardSvr"                                     # Windows Smart Card Service
        "SysMain"                                      # Analyses System Usage and Improves Performance
        "UevAgentService"                              # User Experience Virtualization Service
        "lfsvc"                                        # Geolocation Service
        "icssvc"                                       # Windows Mobile Hotspot Service 
        "iphlpsvc"                                     # IP Helper
        "WpcMonSvc"                                    # Parental Controls
        "WerSvc"                                       # Windows error reporting
        "WbioSrvc"                                     # Windows Biometric Service
        "wisvc"                                        # Windows Insider program(Windows Insider will not work if Disabled)
    )

    foreach ($service in $services_d) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist
        Write-Host "Setting $service StartupType to Disabled" -ForegroundColor Red
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Art -artN "
=======================================
----- Services set to Gaming Mode -----
=======================================
" -ch Cyan
    Invoke-MessageBox "tweak"
}