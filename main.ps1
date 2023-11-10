Add-Type -AssemblyName PresentationFramework

<#
.NOTES
    Author      : Vuk1lis
    GitHub      : https://github.com/vukilis
    Version 1.1
#>

Start-Transcript $ENV:TEMP\Windows11_Optimizer_Debloater.log -Append

# $xamlFile="M:\Windows11-Optimizer&Debloater\MainWindow.xaml" #uncomment for development
# $inputXAML=Get-Content -Path $xamlFile -Raw #uncomment for development
$inputXAML = (new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/MainWindow.xaml") #uncomment for Production
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"', '' -replace 'x:N', "N" -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[XML]$XAML=$inputXAML

# Check if chocolatey is installed and get its version
if ((Get-Command -Name choco -ErrorAction Ignore) -and ($chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion)) {
    Write-Output "Chocolatey Version $chocoVersion is already installed"
}else {
    Write-Output "Seems Chocolatey is not installed, installing now"
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    powershell choco feature enable -n allowGlobalConfirmation
}

$reader = New-Object System.Xml.XmlNodeReader $XAML
try {
    $psform=[Windows.Markup.XamlReader]::Load($reader)
}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    If ($error[0].Exception.Message -like "*button*") {
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"
    }
}
catch {
    ### If it broke some other way <img draggable="false" role="img" class="emoji" alt="😀" src="https://s0.wp.com/wp-content/mu-plugins/wpcom-smileys/twemoji/2/svg/1f600.svg">
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    try {
        Set-Variable -Name "wpf_$($_.Name)" -Value $psform.FindName($_.Name) -ErrorAction Stop
    }
    catch {
        throw
    }
}

$buttons = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "Button"}
foreach ($button in $buttons){
    $button.value.Add_Click({
        [System.Object]$Sender = $args[0]
        Invoke-Button "wpf_$($Sender.name)"
    })
}
function Invoke-Button {
    <#
        .DESCRIPTION
        Meant to make creating buttons easier.
        This way you can dictate what each button does from this function. 
    
        Input will be the name of the button that is clicked. 
    #>

    Param ([string]$Button) 

    #Use this to get the name of the button
    #[System.Windows.MessageBox]::Show("$Button","Windows11-OptimizerDebloater","OK","Info")

    Switch -Wildcard ($Button){

        "wpf_Tab?BT" {Invoke-Tabs $Button}
        "wpf_debloatALL" {Invoke-debloatALL}
        "wpf_debloatGaming" {Invoke-debloatGaming}
        "wpf_optimizationButton" {Invoke-optimizationButton}
        "wpf_recommended" {Invoke-recommended}
        "wpf_gaming" {Invoke-gaming}
        "wpf_normal" {Invoke-normal}
        "wpf_PanelControl" {Invoke-Configs -Panel $button}
        "wpf_PanelPnF" {Invoke-Configs -Panel $button}
        "wpf_PanelNetwork" {Invoke-Configs -Panel $button}
        "wpf_PanelPower" {Invoke-Configs -Panel $button}
        "wpf_PanelSound" {Invoke-Configs -Panel $button}
        "wpf_PanelSystem" {Invoke-Configs -Panel $button}
        "wpf_PanelUser" {Invoke-Configs -Panel $button}
        "wpf_PanelServices" {Invoke-Configs -Panel $button}
        "wpf_PanelWindowsFirewall" {Invoke-Configs -Panel $button}
        "wpf_PanelDeviceManager" {Invoke-Configs -Panel $button}
        "wpf_PanelExplorerOption" {Invoke-Configs -Panel $button}
        "wpf_PanelRegedit" {Invoke-Configs -Panel $button}
        "wpf_PanelScheduler" {Invoke-Configs -Panel $button}
        "wpf_PanelResourceMonitor" {Invoke-Configs -Panel $button}
        "wpf_PanelSysConf" {Invoke-Configs -Panel $button}
        "wpf_PanelEvent" {Invoke-Configs -Panel $button}
        "wpf_PanelSysInfo" {Invoke-Configs -Panel $button}
        "wpf_PanelDiskManagement" {Invoke-Configs -Panel $button}
        "wpf_Updatesdefault" {Invoke-UpdatesDefault}
        "wpf_FixesUpdate" {Invoke-FixesUpdate}
        "wpf_Updatesdisable" {Invoke-UpdatesDisable}
        "wpf_Updatessecurity" {Invoke-UpdatesSecurity}
        "wpf_FeatureInstall" {Invoke-FeatureInstall}
        "wpf_PanelAutologin" {Invoke-PanelAutologin}
    }
}

################################
####  Navigation Controls  #####
################################
function Invoke-Tabs {
    <#
    
        .DESCRIPTION
        Sole purpose of this fuction reduce duplicated code for switching between tabs. 
    #>

    Param ($ClickedTab)
    $Tabs = Get-Variable wpf_Tab?BT
    $TabNav = Get-Variable wpf_TabNav
    $x = [int]($ClickedTab -replace "wpf_Tab","" -replace "BT","") - 1

    0..($Tabs.Count -1 ) | ForEach-Object {
        
        if ($x -eq $psitem){
            $TabNav.value.Items[$psitem].IsSelected = $true
        }
        else{
            $TabNav.value.Items[$psitem].IsSelected = $false
        }
    }
}

################################
#########  Functions  ##########
################################

Function Get-Author {
    Clear-Host
    $art = @"
 __      __          _      __   _   _       
 \ \    / /         | |    /_ | | | (_)      
  \ \  / /   _   _  | | __  | | | |  _   ___ 
   \ \/ /   | | | | | |/ /  | | | | | | / __|
    \  /    | |_| | |   <   | | | | | | \__ \
     \/      \__,_| |_|\_\  |_| |_| |_| |___/

          https://github.com/vukilis/
         Windows11 Optimizer&Debloater
"@
    for ($i=0;$i -lt $art.length;$i++) {
        if ($i%2) {
            $ch = "Magenta"
        }
        elseif ($i%5) {
            $ch = "Cyan"
        }
        elseif ($i%7) {
            $ch = "DarkRed"
        }
        else {
            $ch = "DarkMagenta"
        }
        write-host $art[$i] -NoNewline -ForegroundColor $ch
    }

    Write-Host "`n"
}

function Art {
    param ($artN, $ch)
    for ($i=0;$i -lt $artN.length;$i++) {
        $ch
        write-host $artN[$i] -NoNewline -ForegroundColor $ch
    }
    Write-Host "`n"
    return $artN, $ch
}

### Get all variables from form
# Get-Variable wpf_*

########################################### INFO ###########################################    
# HARDWARE INFO
$pcName=[System.Net.Dns]::GetHostName()
$wpf_pcName.Content="Welcome $pcName"

$cpuInfo=Get-CimInstance -ClassName CIM_Processor | Select-Object *
$wpf_cpuInfo.Content=$cpuInfo.Name

# $gpuInfo=Get-CimInstance -ClassName win32_VideoController | Select-Object *
# $wpf_gpuInfo.Content=$gpuInfo.Name[0]

Get-CimInstance -ClassName win32_VideoController | ForEach-Object {[void]$wpf_gpuInfo.Items.Add($_.VideoProcessor)}

# $ramInfo=(Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
# $ramSpeed=Get-WmiObject Win32_PhysicalMemory | Select-Object *
# $wpf_ramInfo.Content=$ramSpeed.Manufacturer[0]+" "+ $ramInfo+"GB" +" "+ $ramSpeed.ConfiguredClockSpeed[0]+"MT/s"

$ramInfo = get-wmiobject -class Win32_ComputerSystem
$ramInfoGB=[math]::Ceiling($ramInfo.TotalPhysicalMemory / 1024 / 1024 / 1024)
#$ramInfoGB=[math]::Ceiling((Get-WMIObject Win32_OperatingSystem).TotalVisibleMemorySize / 1MB)
$ramSpeed=Get-WmiObject Win32_PhysicalMemory | Select-Object *
$IsVirtual=$ramInfo.Model.Contains("Virtual")
if ($IsVirtual -like 'False'){
    Write-Output "This Machine is Physical Platform"
    $wpf_ramInfo.Content=[string]$ramInfoGB+"GB"+" "+ $ramSpeed.ConfiguredClockSpeed[0]+"MT/s"
} else{
    Write-Output "This Machine is Virtual Platform"
    $wpf_ramInfo.Content=[string]$ramInfoGB+"GB"
}

$mbInfo=Get-CimInstance -ClassName win32_baseboard | Select-Object *
$wpf_mbInfo.Content=$mbInfo.Product

# OS INFO
# $osInfo=systeminfo /fo csv | ConvertFrom-Csv | Select-Object *
# $wpf_osInfo.Content=$osInfo."OS Name"
$osInfo=(Get-CimInstance -class Win32_OperatingSystem).Caption
$wpf_osInfo.Content=$osInfo

$verInfo=(Get-CimInstance Win32_OperatingSystem).BuildNumber
$wpf_verInfo.Content=$verInfo

$installTimeInfo=(Get-CimInstance Win32_OperatingSystem).InstallDate
$wpf_installTimeInfo.Content=$installTimeInfo

$licenceInfo=Get-CimInstance SoftwareLicensingProduct -Filter "partialproductkey is not null" | Where-Object name -like windows*
$licenceCheckInfo=$licenceInfo.LicenseStatus
if ($licenceCheckInfo -eq 1) {
    $licenceCheckInfo = "Active"
}else {
    $licenceCheckInfo = "Not Active"
}
$wpf_licenceInfo.Content=$licenceCheckInfo

#DISK INFO
Get-Disk | ForEach-Object {[void]$wpf_diskNameInfo.Items.Add($_.FriendlyName)}
function Get-DiskInfo {
    $diskSelected=$wpf_diskNameInfo.SelectedItem
    $details=Get-Disk -FriendlyName "$diskSelected" | Select-Object *
    $wpf_diskStatus.Content=$details.HealthStatus
    $wpf_diskStyle.Content=$details.PartitionStyle
}

Get-WmiObject -Class win32_logicaldisk | ForEach-Object {[void]$wpf_diskName.Items.Add($_.DeviceId)}
function Get-DiskSize {
    $diskSelected=$wpf_diskName.SelectedItem
    $details=Get-WmiObject -Class win32_logicaldisk -Filter  "DeviceID = '$diskSelected'" | Select-Object *
    $wpf_diskMaxSize.Content=("{0}GB" -f [math]::truncate($details.Size / 1GB))
    $wpf_diskFreeSize.Content=("{0}GB" -f [math]::truncate($details.FreeSpace / 1GB))
}

########################################### /INFO ###########################################    
########################################### /DEBLOAT ###########################################    

function Remove-WinUtilAPPX {
    <#
        .DESCRIPTION
        This function will remove any of the provided APPX names
        .EXAMPLE
        Remove-WinUtilAPPX -Name "Microsoft.Microsoft3DViewer"
    #>
    param (
        $Name
    )

    Try{
        Write-Host "Removing $Name"
        Get-AppxPackage "*$Name*" | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$Name*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Catch [System.Exception] {
        if($psitem.Exception.Message -like "*The requested operation requires elevation*"){
            Write-Warning "Unable to uninstall $name due to a Security Exception"
        }
        Else{
            Write-Warning "Unable to uninstall $name due to unhandled exception"
            Write-Warning $psitem.Exception.StackTrace 
        }
    }
    Catch{
        Write-Warning "Unable to uninstall $name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace 
    }
}
function Invoke-debloatGaming{
    $appx = @(
        "Microsoft.Microsoft3DViewer"
        "Microsoft.AppConnector"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        #"Microsoft.BingWeather"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.MinecraftUWP"
        #"Microsoft.GamingServices"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.Sway"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsSoundRecorder"
        #"Microsoft.XboxApp"
        "Microsoft.ConnectivityStore"
        "Microsoft.CommsPhone"
        "Microsoft.ScreenSketch"
        #"Microsoft.Xbox.TCUI"
        #"Microsoft.XboxGameOverlay"
        #"Microsoft.XboxGameCallableUI"
        #"Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.MixedReality.Portal"
        #"Microsoft.XboxIdentityProvider"
        #"Microsoft.ZuneMusic"
        #"Microsoft.ZuneVideo"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftStickyNotes"
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Royal Revolt*"
        "*Sway*"
        "*Speed Test*"
        "*Dolby*"
        "*Viber*"
        "*ACGMediaPlayer*"
        "*Netflix*"
        "*OneCalendar*"
        "*LinkedInforWindows*"
        "*HiddenCityMysteryofShadows*"
        "*Hulu*"
        "*HiddenCity*"
        "*AdobePhotoshopExpress*"
        "*HotspotShieldFreeVPN*"
        "*Microsoft.Advertising.Xaml*"
    )

    foreach ($app in $appx) {
        Remove-WinUtilAPPX $app
    }
    
    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

    Write-Host \"Stopping Teams process...\"
    Stop-Process -Name \"*teams*\" -Force -ErrorAction SilentlyContinue

    Write-Host \"Uninstalling Teams from AppData\\Microsoft\\Teams\"
    if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
        # Uninstall app
        $proc = Start-Process $TeamsUpdateExePath \"-uninstall -s\" -PassThru
        $proc.WaitForExit()
    }

    Write-Host \"Removing Teams AppxPackage...\"
    Get-AppxPackage \"*Teams*\" | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage \"*Teams*\" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    Write-Host \"Deleting Teams directory\"
    if ([System.IO.Directory]::Exists($TeamsPath)) {
        Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    Write-Host \"Deleting Teams uninstall registry key\"
    # Uninstall from Uninstall registry key UninstallString
    $us = (Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -like '*Teams*'}).UninstallString
    if ($us.Length -gt 0) {
        $us = ($us.Replace('/I', '/uninstall ') + ' /quiet').Replace('  ', ' ')
        $FilePath = ($us.Substring(0, $us.IndexOf('.exe') + 4).Trim())
        $ProcessArgs = ($us.Substring($us.IndexOf('.exe') + 5).Trim().replace('  ', ' '))
        $proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
        $proc.WaitForExit()
    }
    Art -artN "
=========================
----- Apps removed -----
========================
" -ch Cyan
}
function Invoke-debloatALL{
    $appx = @(
        "Microsoft.Microsoft3DViewer"
        "Microsoft.AppConnector"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingWeather"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.MinecraftUWP"
        "Microsoft.GamingServices"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.Sway"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.XboxApp"
        "Microsoft.ConnectivityStore"
        "Microsoft.CommsPhone"
        "Microsoft.ScreenSketch"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.MixedReality.Portal"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftStickyNotes"
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Royal Revolt*"
        "*Sway*"
        "*Speed Test*"
        "*Dolby*"
        "*Viber*"
        "*ACGMediaPlayer*"
        "*Netflix*"
        "*OneCalendar*"
        "*LinkedInforWindows*"
        "*HiddenCityMysteryofShadows*"
        "*Hulu*"
        "*HiddenCity*"
        "*AdobePhotoshopExpress*"
        "*HotspotShieldFreeVPN*"
        "*Microsoft.Advertising.Xaml*"
    )

    foreach ($app in $appx) {
        Remove-WinUtilAPPX $app
    }
    
    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

    Write-Host \"Stopping Teams process...\"
    Stop-Process -Name \"*teams*\" -Force -ErrorAction SilentlyContinue

    Write-Host \"Uninstalling Teams from AppData\\Microsoft\\Teams\"
    if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
        # Uninstall app
        $proc = Start-Process $TeamsUpdateExePath \"-uninstall -s\" -PassThru
        $proc.WaitForExit()
    }

    Write-Host \"Removing Teams AppxPackage...\"
    Get-AppxPackage \"*Teams*\" | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage \"*Teams*\" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    Write-Host \"Deleting Teams directory\"
    if ([System.IO.Directory]::Exists($TeamsPath)) {
        Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    Write-Host \"Deleting Teams uninstall registry key\"
    # Uninstall from Uninstall registry key UninstallString
    $us = (Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -like '*Teams*'}).UninstallString
    if ($us.Length -gt 0) {
        $us = ($us.Replace('/I', '/uninstall ') + ' /quiet').Replace('  ', ' ')
        $FilePath = ($us.Substring(0, $us.IndexOf('.exe') + 4).Trim())
        $ProcessArgs = ($us.Substring($us.IndexOf('.exe') + 5).Trim().replace('  ', ' '))
        $proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
        $proc.WaitForExit()
    }
    Art -artN "
=========================
----- Apps removed -----
========================
" -ch Cyan
}

########################################### /DEBLOAT ###########################################   
########################################### SERVICES ###########################################    

$wpf_pBar.Visibility = "Hidden"

$wpf_recommended.Add_MouseLeave({
    $wpf_pBar.Visibility = "Hidden"
})
function Invoke-recommended{
    # Set-Presets "recommended"
    $services = @(
        "ALG"                                          # Application Layer Gateway Service(Provides support for 3rd party protocol plug-ins for Internet Connection Sharing)
        "AJRouter"                                     # Needed for AllJoyn Router Service
        "BcastDVRUserService_48486de"                  # GameDVR and Broadcast is used for Game Recordings and Live Broadcasts
        "Browser"                                      # Let users browse and locate shared resources in neighboring computers
        "BthAvctpSvc"                                  # AVCTP service (needed for Bluetooth Audio Devices or Wireless Headphones)
        "CaptureService_48486de"                       # Optional screen capture functionality for applications that call the Windows.Graphics.Capture API.
        "cbdhsvc_48486de"                              # Clipboard Service
        "diagnosticshub.standardcollector.service"     # Microsoft (R) Diagnostics Hub Standard Collector Service
        "DiagTrack"                                    # Diagnostics Tracking Service
        "dmwappushservice"                             # WAP Push Message Routing Service
        "DPS"                                          # Diagnostic Policy Service (Detects and Troubleshoots Potential Problems)
        "edgeupdate"                                   # Edge Update Service
        "edgeupdatem"                                  # Another Update Service
        "Fax"                                          # Fax Service
        "fhsvc"                                        # Fax History
        "FontCache"                                    # Windows font cache
        "gupdate"                                      # Google Update
        "gupdatem"                                     # Another Google Update Service
        "lfsvc"                                        # Geolocation Service
        "lmhosts"                                      # TCP/IP NetBIOS Helper
        "MapsBroker"                                   # Downloaded Maps Manager
        "MicrosoftEdgeElevationService"                # Another Edge Update Service
        "MSDTC"                                        # Distributed Transaction Coordinator
        "NahimicService"                               # Nahimic Service
        "NetTcpPortSharing"                            # Net.Tcp Port Sharing Service
        "PcaSvc"                                       # Program Compatibility Assistant Service
        "PerfHost"                                     # Remote users and 64-bit processes to query performance.
        "PhoneSvc"                                     # Phone Service(Manages the telephony state on the device)
        "PrintNotify"                                  # Windows printer notifications and extentions
        "QWAVE"                                        # Quality Windows Audio Video Experience (audio and video might sound worse)
        "RemoteAccess"                                 # Routing and Remote Access
        "RemoteRegistry"                               # Remote Registry
        "RetailDemo"                                   # Demo Mode for Store Display
        "RtkBtManServ"                                 # Realtek Bluetooth Device Manager Service
        "SCardSvr"                                     # Windows Smart Card Service
        "seclogon"                                     # Secondary Logon (Disables other credentials only password will work)
        "SEMgrSvc"                                     # Payments and NFC/SE Manager (Manages payments and Near Field Communication (NFC) based secure elements)
        "SharedAccess"                                 # Internet Connection Sharing (ICS)
        "ssh-agent"                                    # OpenSSH Authentication Agent
        "stisvc"                                       # Windows Image Acquisition (WIA)
        "SysMain"                                      # Analyses System Usage and Improves Performance
        "TrkWks"                                       # Distributed Link Tracking Client
        "WerSvc"                                       # Windows error reporting
        "wisvc"                                        # Windows Insider program(Windows Insider will not work if Disabled)
        "WMPNetworkSvc"                                # Windows Media Player Network Sharing Service
        "WpcMonSvc"                                    # Parental Controls
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
    
    $wpf_pBar.Visibility = "Visible"
    $i=$services.Count
    $wpf_pBar.Maximum = $i

    $counter = 1
    foreach ($service in $services) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist

        $ii=$counter++
        $wpf_pBar.Value = $ii
        
        Write-Host "Setting $service StartupType to Manual"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
    }
    Art -artN "
======================================
-- Services set to Recommended Mode --
======================================
" -ch Cyan
}
$wpf_gaming.Add_MouseLeave({
    $wpf_pBar.Visibility = "Hidden"
})
function Invoke-gaming{
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

    $wpf_pBar.Visibility = "Visible"
    $i=$services.Count
    $wpf_pBar.Maximum = $i

    $counter = 1
    foreach ($service in $services_m) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist

        $ii=$counter++
        $wpf_pBar.Value = $ii
        
        Write-Host "Setting $service StartupType to Manual"
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

    $wpf_pBar.Visibility = "Visible"
    $i=$services.Count
    $wpf_pBar.Maximum = $i

    $counter = 1
    foreach ($service in $services_d) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist

        $ii=$counter++
        $wpf_pBar.Value = $ii
        
        Write-Host "Setting $service StartupType to Disabled"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Art -artN "
=======================================
----- Services set to Gaming Mode -----
=======================================
" -ch Cyan
}
function Invoke-normal{
    #Set-Presets "normal"
    cmd /c services.msc
}

Get-Service | ForEach-Object {[void]$wpf_ddlServices.Items.Add($_.Name)}
function Get-Services {
    $ServiceName=$wpf_ddlServices.SelectedItem
    $details=Get-Service -Name $ServiceName | Select-Object *
    $wpf_lblName.Content=$details.DisplayName
    $wpf_lblStatus.Content=$details.Status
    $wpf_lblStartupType.Content=$details.StartupType

    ### display info about service
    $wpf_lblServicesDesc.Text=$details.Description

    ### status color
    if ($wpf_lblStatus.Content -eq 'Running') {
        $wpf_lblStatus.Foreground='green'
    }else{
        $wpf_lblStatus.Foreground='red'
    }

    ### type color
    if ($wpf_lblStartupType.Content -eq 'Running') {
        $wpf_lblStartupType.Foreground='green'
    }elseif ($wpf_lblStartupType.Content -eq 'Manual'){
        $wpf_lblStartupType.Foreground='yellow'
    }elseif($wpf_lblStartupType.Content -eq 'Automatic'){
        $wpf_lblStartupType.Foreground='blue'
    }else{
        $wpf_lblStartupType.Foreground='red'
    }
}

########################################### /SERVICES ########################################### 
########################################### OPTIMIZATION ########################################### 

function Invoke-optimizationButton{
    # Essential Tweaks
    If ( $wpf_DblTelemetry.IsChecked -eq $true ) {
        Write-Host "Disabling Telemetry..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
        Write-Host "Disabling Application suggestions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
        Write-Host "Disabling Feedback..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Disabling Tailored Experiences..."
        If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
        Write-Host "Disabling Advertising ID..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
        Write-Host "Disabling Error reporting..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
        Write-Host "Restricting Windows Update P2P only to local network..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
        Write-Host "Stopping and disabling Diagnostics Tracking Service..."
        Stop-Service "DiagTrack" -WarningAction SilentlyContinue
        Set-Service "DiagTrack" -StartupType Disabled
        Write-Host "Stopping and disabling WAP Push Service..."
        Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
        Set-Service "dmwappushservice" -StartupType Disabled
        Write-Host "Enabling F8 boot menu options..."
        bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
        Write-Host "Disabling Remote Assistance..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
        Write-Host "Stopping and disabling Superfetch service..."
        Stop-Service "SysMain" -WarningAction SilentlyContinue
        Set-Service "SysMain" -StartupType Disabled

        # Task Manager Details
        If ((get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild -lt 22557) {
            Write-Host "Showing task manager details..."
            $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
            Do {
                Start-Sleep -Milliseconds 100
                $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
            } Until ($preferences)
            Stop-Process $taskmgr
            $preferences.Preferences[28] = 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
        }
        else { Write-Host "Task Manager patch not run in builds 22557+ due to bug" }

        Write-Host "Showing file operations details..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
        Write-Host "Hiding Task View button..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
        Write-Host "Hiding People icon..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

        Write-Host "Changing default Explorer view to This PC..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

        ## Enable Long Paths
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWORD -Value 1

        Write-Host "Hiding 3D Objects icon from This PC..."
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue  

        ## Performance Tweaks and More Telemetry
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Type DWord -Value 400
        
        ## Timeout Tweaks cause flickering on Windows now
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LowLevelHooksTimeout" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillServiceTimeout" -ErrorAction SilentlyContinue

        # Network Tweaks
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type DWord -Value 20
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 4294967295

        # Gaming Tweaks
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Affinity" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Background Only" -Type String -Value "False"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Clock Rate" -Type DWord -Value 10000
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Type DWord -Value 8
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Type DWord -Value 6
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Type String -Value "High"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "SFIO Priority" -Type String -Value "High"

        # Group svchost.exe processes
        $ram = (Get-CimInstance -ClassName "Win32_PhysicalMemory" | Measure-Object -Property Capacity -Sum).Sum / 1kb
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force

        Write-Host "Disable News and Interests"
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
        # Remove "News and Interest" from taskbar
        Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

        # remove "Meet Now" button from taskbar

        If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
        }

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type DWord -Value 1

        Write-Host "Removing AutoLogger file and restricting directory..."
        $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
        If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
            Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
        }
        icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

        Write-Host "Stopping and disabling Diagnostics Tracking Service..."
        Stop-Service "DiagTrack"
        Set-Service "DiagTrack" -StartupType Disabled

        Write-Host "Doing Security checks for Administrator Account and Group Policy"
        if (([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).IndexOf('Administrator') -eq -1) {
            net user administrator /active:no
        }

        $wpf_DblTelemetry.IsChecked = $false
    }
    If ( $wpf_DblWifi.IsChecked -eq $true ) {
        Write-Host "Disabling Wi-Fi Sense..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
        $wpf_DblWifi.IsChecked = $false
    }
    If ( $wpf_DblAH.IsChecked -eq $true ) {
            Write-Host "Disabling Activity History..."
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
            $wpf_DblAH.IsChecked = $false
    }
    If ( $wpf_DblDeleteTempFiles.IsChecked -eq $true ) {
        Write-Host "Delete Temp Files"
        Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path $env:TEMP *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        $wpf_DblDeleteTempFiles.IsChecked = $false
        Write-Host "======================================="
        Write-Host "--- Cleaned following folders:"
        Write-Host "--- C:\Windows\Temp"
        Write-Host "--- "$env:TEMP
        Write-Host "======================================="
    }
    If ( $wpf_DblDiskCleanup.IsChecked -eq $true ) {
        Write-Host "Running Disk Cleanup on Drive C:..."
        cmd /c cleanmgr.exe /d C: /VERYLOWDISK
        $wpf_DblDiskCleanup.IsChecked = $false
    }
    If ( $wpf_DblLocTrack.IsChecked -eq $true ) {
        Write-Host "Disabling Location Tracking..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
        Write-Host "Disabling automatic Maps updates..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
        $wpf_DblLocTrack.IsChecked = $false
    }
    If ( $wpf_DblStorage.IsChecked -eq $true ) {
        Write-Host "Disabling Storage Sense..."
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
        $wpf_DblStorage.IsChecked = $false
    }
    If ( $wpf_DblHiber.IsChecked -eq $true  ) {
        Write-Host "Disabling Hibernation..."
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type Dword -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0
        $wpf_DblHiber.IsChecked = $false
    }
    If ( $wpf_DblDVR.IsChecked -eq $true ) {
        If (!(Test-Path "HKCU:\System\GameConfigStore")) {
            New-Item -Path "HKCU:\System\GameConfigStore" -Force
        }
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWord -Value 2
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

        $wpf_DblDVR.IsChecked = $false
    }

    # Additional Tweaks
    If ( $wpf_DblPower.IsChecked -eq $true ) {
        If (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling") {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Type DWord -Value 00000001
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0000000
        $wpf_DblPower.IsChecked = $false 
    }
    If ( $wpf_DblNum.IsChecked -eq $true ) {
        Write-Host "Enabling NumLock after startup..."
        If (!(Test-Path "HKU:")) {
            New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
        }
        Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2
        $wpf_DblNum.IsChecked = $false
    }
    If ( $wpf_DblExt.IsChecked -eq $true ) {
        Write-Host "Showing known file extensions..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
        $wpf_DblExt.IsChecked = $false
    }
    If ( $wpf_DblDisplay.IsChecked -eq $true ) {
        # https://www.tenforums.com/tutorials/6377-change-visual-effects-settings-windows-10-a.html
        # https://superuser.com/questions/1244934/reg-file-to-modify-windows-10-visual-effects
        Write-Host "Adjusting visual effects for performance..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name "FontSmoothing" -Value 2
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144, 18, 3, 128, 18, 0, 0, 0))
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1
        Write-Host "Adjusted visual effects for performance"
        $wpf_DblDisplay.IsChecked = $false
    }
    If ( $wpf_DblUTC.IsChecked -eq $true ) {
        Write-Host "Setting BIOS time to UTC..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
        $wpf_DblUTC.IsChecked = $false
    }
    If ( $wpf_DblDisableUAC.IsChecked -eq $true) {
        Write-Host "Disabling UAC..."
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Type DWord -Value 0 # Default is 5
        # This will set the GPO Entry in Security so that Admin users elevate without any prompt while normal users still elevate and u can even leave it ennabled.
        $wpf_DblDisableUAC.IsChecked = $false
    }
    If ( $wpf_DblDisableNotifications.IsChecked -eq $true ) {
        Write-Host "Disabling Notifications and Action Center..."
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows" -Name "Explorer" -force
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -PropertyType "DWord" -Value 1
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -PropertyType "DWord" -Value 0 -force
        $wpf_DblDisableNotifications.IsChecked = $false
    }
    If ( $wpf_DblDisableMouseAcceleration.IsChecked -eq $true ) {
        Write-Host "Disabling mouse acceleration..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type String -Value 0
        $wpf_DblDisableMouseAcceleration.IsChecked = $false
    }
    If ( $wpf_DblRemoveCortana.IsChecked -eq $true ) {
        Write-Host "Removing Cortana..."
        Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
        $wpf_DblRemoveCortana.IsChecked = $false
    }
    If ( $wpf_DblRightClickMenu.IsChecked -eq $true ) {
        Write-Host "Setting Classic Right-Click Menu..."
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -force -value ""       
        $wpf_DblRightClickMenu.IsChecked = $false
    }
    If ( $wpf_DblGameMode.IsChecked -eq $true ) {
        Write-Host "Enabling Game Mode..."
        If (Test-Path HKCU:\Software\Microsoft\GameBar) {Get-Item HKCU:\Software\Microsoft\GameBar|Set-ItemProperty -Name AllowAutoGameMode -Value 1 -Verbose -Force}
        $wpf_DblGameMode.IsChecked -eq $false
    }
    If ( $wpf_DblGameBar.IsChecked -eq $true ) {
        Write-Host "Disabling Game Bar..."
        If (Test-Path "HKCU:\Software\Microsoft\GameBar") {Get-Item "HKCU:\Software\Microsoft\GameBar"|Set-ItemProperty -Name "UseNexusForGameBarEnabled" -Value 0 -Verbose -Force}
        $wpf_DblGameBar.IsChecked = $false
    }
    If ( $wpf_DblGameBar.IsChecked -eq $true ) {
        Write-Host "Disabling Game Bar..."
        If (Test-Path "HKCU:\Software\Microsoft\GameBar") {Get-Item "HKCU:\Software\Microsoft\GameBar"|Set-ItemProperty -Name "UseNexusForGameBarEnabled" -Value 0 -Verbose -Force}
        $wpf_DblGameBar.IsChecked = $false
    }
    If ( $wpf_DblPersonalize.IsChecked -eq $true ) {
        #hide search icon, show transparency effect, colors, lock screen, power
        Write-Host "Adjusting personalisation settings..."
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideTaskViewButton" -PropertyType "DWord" -Value 1 -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideTaskViewButton" -PropertyType "DWord" -Value 1 -Force
        
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -PropertyType "DWord" -Value 1 -Force
        
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoColorization" -PropertyType "DWord" -Value 0 -Force
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentColorMenu" -PropertyType "DWord" -Force -Value 0xffd47800
        #New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentPalette" -PropertyType "BINARY" -Force -Value '99,eb,ff,00,4c,c2,ff,00,00,91,f8,00,00,78,d4,00,00,67,c0,00,00,3e,92,00,00,1a,68,00,f7,63,0c,00'
        
        #Accent Palette Key
        $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
        $AccentPaletteKey = @{
            Key   = 'AccentPalette';
            Type  = "BINARY";
            Value = '99,eb,ff,00,4c,c2,ff,00,00,91,f8,00,00,78,d4,00,00,67,c0,00,00,3e,92,00,00,1a,68,00,f7,63,0c,00'
        }
        $hexified = $AccentPaletteKey.Value.Split(',') | ForEach-Object { "0x$_" }

        If ($Null -eq (Get-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -ErrorAction SilentlyContinue))
        {
            New-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -PropertyType Binary -Value ([byte[]]$hexified)
        }
        Else
        {
            Set-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -Value ([byte[]]$hexified) -Force
        }
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "StartColorMenu" -PropertyType "DWord" -Force -Value 0xffc06700
        
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -PropertyType "DWord" -Value 0 -Force
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -PropertyType "DWord" -Value 0 -Force

        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -PropertyType "DWord" -Force -Value 1
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenSlideshow" -PropertyType "DWord" -Force -Value 1
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -PropertyType "DWord" -Force -Value 1
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RemediationRequired" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314563Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -PropertyType "DWord" -Force -Value 0
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -PropertyType "DWord" -Force -Value 0
        
        powercfg -x -disk-timeout-ac 0
        powercfg -x -disk-timeout-dc 0
        powercfg -x -monitor-timeout-ac 20
        powercfg -x -monitor-timeout-dc 20


        $wpf_DblPersonalize.IsChecked = $false
    }
}

function Get-AppsUseLightTheme{
    return (Get-ItemProperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize').AppsUseLightTheme
}

function Get-SystemUsesLightTheme{
    return (Get-ItemProperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize').SystemUsesLightTheme
}

$wpf_ToggleDarkMode.IsChecked = $(If ($(Get-AppsUseLightTheme) -eq 0 -And $(Get-SystemUsesLightTheme) -eq 0) {$true} Else {$false})

$wpf_ToggleDarkMode.Add_Click({    
    $EnableDarkMode = $wpf_ToggleDarkMode.IsChecked
    $DarkMoveValue = $(If ( $EnableDarkMode ) {0} Else {1})
    Write-Host $(If ( $EnableDarkMode ) {"Enabling Dark Mode"} Else {"Disabling Dark Mode"})
    $Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    If ($DarkMoveValue -ne $(Get-AppsUseLightTheme))
    {
        Set-ItemProperty $Theme AppsUseLightTheme -Value $DarkMoveValue
    }
    If ($DarkMoveValue -ne $(Get-SystemUsesLightTheme))
    {
        Set-ItemProperty $Theme SystemUsesLightTheme -Value $DarkMoveValue
    }
    Write-Host $(If ( $EnableDarkMode ) {"Enabled"} Else {"Disabled"})
    }
)

$wpf_fastPresetButton.Add_Click({    
    $EnableDarkMode = $wpf_fastPresetButton.IsChecked
    $DarkMoveValue = $(If ( $EnableDarkMode ) {0} Else {1})
    Write-Host $(If ( $EnableDarkMode ) {"Enabling Tweak Preset"} Else {"Disabling Tweak Preset"})
    If ($DarkMoveValue -ne 1){
        $wpf_DblTelemetry.IsChecked=$true
        $wpf_DblWifi.IsChecked=$true
        $wpf_DblAH.IsChecked=$true
        $wpf_DblLocTrack.IsChecked=$true
        $wpf_DblStorage.IsChecked=$true
        $wpf_DblHiber.IsChecked=$true
        $wpf_DblDVR.IsChecked=$true
        $wpf_DblPower.IsChecked=$true
        $wpf_DblNum.IsChecked=$true
        $wpf_DblExt.IsChecked=$true
        $wpf_DblDisplay.IsChecked=$true
        $wpf_DblDisableMouseAcceleration.IsChecked=$true
        $wpf_DblPersonalize.IsChecked=$true
    }
    if ($DarkMoveValue -ne 0){
        $wpf_DblTelemetry.IsChecked=$false
        $wpf_DblWifi.IsChecked=$false
        $wpf_DblAH.IsChecked=$false
        $wpf_DblLocTrack.IsChecked=$false
        $wpf_DblStorage.IsChecked=$false
        $wpf_DblHiber.IsChecked=$false
        $wpf_DblDVR.IsChecked=$false
        $wpf_DblPower.IsChecked=$false
        $wpf_DblNum.IsChecked=$false
        $wpf_DblExt.IsChecked=$false
        $wpf_DblDisplay.IsChecked=$false
        $wpf_DblDisableMouseAcceleration.IsChecked=$false
        $wpf_DblPersonalize.IsChecked=$false
    }
    Write-Host $(If ( $EnableDarkMode ) {"Enabled"} Else {"Disabled"})
    }
)

$wpf_megaPresetButton.Add_Click({    
    $EnableDarkMode = $wpf_megaPresetButton.IsChecked
    $DarkMoveValue = $(If ( $EnableDarkMode ) {0} Else {1})
    Write-Host $(If ( $EnableDarkMode ) {"Enabling Tweak Preset"} Else {"Disabling Tweak Preset"})
    If ($DarkMoveValue -ne 1){
        $wpf_DblTelemetry.IsChecked=$true
        $wpf_DblWifi.IsChecked=$true
        $wpf_DblAH.IsChecked=$true
        $wpf_DblDeleteTempFiles.IsChecked=$true
        $wpf_DblDiskCleanup.IsChecked=$true
        $wpf_DblLocTrack.IsChecked=$true
        $wpf_DblStorage.IsChecked=$true
        $wpf_DblHiber.IsChecked=$true
        $wpf_DblDVR.IsChecked=$true
        $wpf_DblPower.IsChecked=$true
        $wpf_DblNum.IsChecked=$true
        $wpf_DblExt.IsChecked=$true
        $wpf_DblDisplay.IsChecked=$true
        $wpf_DblDisableMouseAcceleration.IsChecked=$true
        $wpf_DblRemoveCortana.IsChecked=$true
        $wpf_DblRightClickMenu.IsChecked=$true
        $wpf_DblDisableUAC.IsChecked=$true
        $wpf_DblPersonalize.IsChecked=$true
    }
    if ($DarkMoveValue -ne 0){
        $wpf_DblTelemetry.IsChecked=$false
        $wpf_DblWifi.IsChecked=$false
        $wpf_DblAH.IsChecked=$false
        $wpf_DblDeleteTempFiles.IsChecked=$false
        $wpf_DblDiskCleanup.IsChecked=$false
        $wpf_DblLocTrack.IsChecked=$false
        $wpf_DblStorage.IsChecked=$false
        $wpf_DblHiber.IsChecked=$false
        $wpf_DblDVR.IsChecked=$false
        $wpf_DblPower.IsChecked=$false
        $wpf_DblNum.IsChecked=$false
        $wpf_DblExt.IsChecked=$false
        $wpf_DblDisplay.IsChecked=$false
        $wpf_DblDisableMouseAcceleration.IsChecked=$false
        $wpf_DblRemoveCortana.IsChecked=$false
        $wpf_DblRightClickMenu.IsChecked=$false
        $wpf_DblDisableUAC.IsChecked=$false
        $wpf_DblPersonalize.IsChecked=$false
    }
    Write-Host $(If ( $EnableDarkMode ) {"Enabled"} Else {"Disabled"})
    }
)

########################################### /OPTIMIZATION ########################################### 
########################################### UPDATES ########################################### 

function Invoke-UpdatesDefault{
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type DWord -Value 3
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
    
    $services = @(
        "BITS"
        "wuauserv"
    )

    foreach ($service in $services) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist

        Write-Host "Setting $service StartupType to Automatic"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
    }
    Write-Host "Enabling driver offering through Windows Update..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    Write-Host "Enabling Windows Update automatic restart..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
    Write-Host "Enabled driver offering through Windows Update"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferQualityUpdatesPeriodInDays " -ErrorAction SilentlyContinue
    Art -artN "
==================================
----- Updates Set to Default -----
==================================
" -ch Cyan
}
function Invoke-UpdatesSecurity{
    Write-Host "Disabling driver offering through Windows Update..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Type DWord -Value 1
    Write-Host "Disabling Windows Update automatic restart..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0
    Write-Host "Disabled driver offering through Windows Update"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -Type DWord -Value 20
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferFeatureUpdatesPeriodInDays" -Type DWord -Value 365
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferQualityUpdatesPeriodInDays " -Type DWord -Value 4

    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Set Security Updates"
    $Messageboxbody = ("Recommended Update settings loaded")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    [System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon)
    Art -artN "
==================================
--- Updates Set to Recommended ---
==================================
" -ch Cyan
}
function Invoke-UpdatesDisable{
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type DWord -Value 1
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0

    $services = @(
        "BITS"
        "wuauserv"
    )

    foreach ($service in $services) {
        # -ErrorAction SilentlyContinue is so it doesn't write an error to stdout if a service doesn't exist

        Write-Host "Setting $service StartupType to Disabled"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    }
    Art -artN "
==================================
------ Updates ARE DISABLED ------
==================================
" -ch DarkRed
}
function Invoke-FixesUpdate{
    ### Reset Windows Update Script - reregister dlls, services, and remove registry entires.
    Write-Host "1. Stopping Windows Update Services..." 
    Stop-Service -Name BITS 
    Stop-Service -Name wuauserv 
    Stop-Service -Name appidsvc 
    Stop-Service -Name cryptsvc 

    Write-Host "2. Remove QMGR Data file..." 
    Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue 

    Write-Host "3. Renaming the Software Distribution and CatRoot Folder..." 
    Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue 
    Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue 

    Write-Host "4. Removing old Windows Update log..." 
    Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue 

    Write-Host "5. Resetting the Windows Update Services to defualt settings..." 
    "sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 
    "sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 
    Set-Location $env:systemroot\system32 

    Write-Host "6. Registering some DLLs..." 
    regsvr32.exe /s atl.dll 
    regsvr32.exe /s urlmon.dll 
    regsvr32.exe /s mshtml.dll 
    regsvr32.exe /s shdocvw.dll 
    regsvr32.exe /s browseui.dll 
    regsvr32.exe /s jscript.dll 
    regsvr32.exe /s vbscript.dll 
    regsvr32.exe /s scrrun.dll 
    regsvr32.exe /s msxml.dll 
    regsvr32.exe /s msxml3.dll 
    regsvr32.exe /s msxml6.dll 
    regsvr32.exe /s actxprxy.dll 
    regsvr32.exe /s softpub.dll 
    regsvr32.exe /s wintrust.dll 
    regsvr32.exe /s dssenh.dll 
    regsvr32.exe /s rsaenh.dll 
    regsvr32.exe /s gpkcsp.dll 
    regsvr32.exe /s sccbase.dll 
    regsvr32.exe /s slbcsp.dll 
    regsvr32.exe /s cryptdlg.dll 
    regsvr32.exe /s oleaut32.dll 
    regsvr32.exe /s ole32.dll 
    regsvr32.exe /s shell32.dll 
    regsvr32.exe /s initpki.dll 
    regsvr32.exe /s wuapi.dll 
    regsvr32.exe /s wuaueng.dll 
    regsvr32.exe /s wuaueng1.dll 
    regsvr32.exe /s wucltui.dll 
    regsvr32.exe /s wups.dll 
    regsvr32.exe /s wups2.dll 
    regsvr32.exe /s wuweb.dll 
    regsvr32.exe /s qmgr.dll 
    regsvr32.exe /s qmgrprxy.dll 
    regsvr32.exe /s wucltux.dll 
    regsvr32.exe /s muweb.dll 
    regsvr32.exe /s wuwebv.dll 

    Write-Host "7) Removing WSUS client settings..." 
    REG DELETE "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f 
    REG DELETE "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f 
    REG DELETE "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f 

    Write-Host "8) Resetting the WinSock..." 
    netsh winsock reset 
    netsh winhttp reset proxy 
    netsh int ip reset

    Write-Host "9) Delete all BITS jobs..." 
    Get-BitsTransfer | Remove-BitsTransfer 

    Write-Host "10) Attempting to install the Windows Update Agent..." 
    If ([System.Environment]::Is64BitOperatingSystem) { 
        wusa Windows8-RT-KB2937636-x64 /quiet 
    }
    else { 
        wusa Windows8-RT-KB2937636-x86 /quiet 
    } 

    Write-Host "11) Starting Windows Update Services..." 
    Start-Service -Name BITS 
    Start-Service -Name wuauserv 
    Start-Service -Name appidsvc 
    Start-Service -Name cryptsvc 

    Write-Host "12) Forcing discovery..." 
    wuauclt /resetauthorization /detectnow 

    Write-Host "Process complete. Please reboot your computer."

    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Reset Windows Update "
    $Messageboxbody = ("Stock settings loaded.`n Please reboot your computer")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    [System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon)
    Write-Host "================================="
    Write-Host "-- Reset ALL Updates to Factory -"
    Write-Host "================================="
    Art -artN "
==================================
-- Reset ALL Updates to Factory --
==================================
" -ch DarkGreen
}

########################################### /UPDATES ########################################### 
########################################### CONFIG ############################################
function Invoke-Configs {
    <#
    .DESCRIPTION
    Simple Switch for lagacy windows
#>
param($Panel)

switch ($Panel){
    "wpf_PanelControl"              {cmd /c control}
    "wpf_PanelPnF"                  {cmd /c appwiz.cpl}
    "wpf_PanelNetwork"              {cmd /c ncpa.cpl}
    "wpf_PanelPower"                {cmd /c powercfg.cpl}
    "wpf_PanelSound"                {cmd /c mmsys.cpl}
    "wpf_PanelSystem"               {cmd /c sysdm.cpl}
    "wpf_PanelUser"                 {cmd /c "control userpasswords2"}
    "wpf_PanelServices"             {cmd /c services.msc}
    "wpf_PanelWindowsFirewall"      {cmd /c firewall.cpl}
    "wpf_PanelDeviceManager"        {cmd /c devmgmt.msc}
    "wpf_PanelExplorerOption"       {cmd /c control folders}
    "wpf_PanelRegedit"              {cmd /c regedit}
    "wpf_PanelScheduler"            {cmd /c taskschd.msc}
    "wpf_PanelResourceMonitor"      {cmd /c resmon}
    "wpf_PanelSysConf"              {cmd /c msconfig}
    "wpf_PanelEvent"                {cmd /c taskschd.msc}
    "wpf_PanelSysInfo"              {cmd /c msinfo32}
    "wpf_PanelDiskManagement"       {cmd /c diskmgmt.msc}
}
}
function Invoke-FeatureInstall {
    <#
    .DESCRIPTION
    GUI Function to install Windows Features
    #>
    If ( $wpf_FeaturesDotnet.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx4-AdvSrvs" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart
    }
    If ( $wpf_FeaturesHyperv.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "HypervisorPlatform" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Tools-All" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-PowerShell" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Hypervisor" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Services" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-Clients" -All -NoRestart
        cmd /c bcdedit /set hypervisorschedulertype classic
        Write-Host "HyperV is now installed and configured. Please Reboot before using."
    }
    If ( $wpf_FeaturesLegacymedia.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "DirectPlay" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "LegacyComponents" -All -NoRestart
    }
    If ( $wpf_FeatureWsl.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
        Write-Host "WSL is now installed and configured. Please Reboot before using."
    }
    If ( $wpf_FeatureNfs.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "ServicesForNFS-ClientOnly" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "ClientForNFS-Infrastructure" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "NFS-Administration" -All -NoRestart
        nfsadmin client stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousUID" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousGID" -Type DWord -Value 0
        nfsadmin client start
        nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i
        Write-Host "NFS is now setup for user based NFS mounts"
    }
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "All features are now installed "
    $Messageboxbody = ("Done")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    [System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon)

    Write-Host "================================="
    Write-Host "---  Features are Installed   ---"
    Write-Host "================================="
}
function Invoke-PanelAutologin {
    <#
        .DESCRIPTION
        PlaceHolder
    #>
    curl.exe -ss "https://live.sysinternals.com/Autologon.exe" -o $env:temp\autologin.exe # Official Microsoft recommendation https://learn.microsoft.com/en-us/sysinternals/downloads/autologon
    cmd /c $env:temp\autologin.exe
}
########################################### /CONFIG ########################################### 
Get-Author
$wpf_diskNameInfo.Add_SelectionChanged({Get-DiskInfo})
$wpf_diskName.Add_SelectionChanged({Get-DiskSize})
$wpf_ddlServices.Add_SelectionChanged({Get-Services})
$psform.ShowDialog() | out-null