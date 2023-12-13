Add-Type -AssemblyName PresentationFramework

<#
.NOTES
    Author      : Vuk1lis
    GitHub      : https://github.com/vukilis
    Version 1.7
#>

Start-Transcript $ENV:TEMP\Windows11_Optimizer_Debloater.log -Append

# $xamlFile="path\to\your\MainWindow.xaml" #uncomment for development
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

$buttons = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "Button"}
foreach ($button in $buttons){
    $button.value.Add_Click({
        [System.Object]$Sender = $args[0]
        Invoke-Button "wpf_$($Sender.name)"
    })
}

$checkbox = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "CheckBox"}
foreach ($box in $checkbox){
    $box.value.Add_Click({
        [System.Object]$Sender = $args[0]
        Invoke-Checkbox "wpf_$($Sender.name)"
    })
}

function Invoke-Button {

    <#
    
        .DESCRIPTION
        Meant to make creating buttons easier. There is a section below in the gui that will assign this function to every button.
        This way you can dictate what each button does from this function. 
    
        Input will be the name of the button that is clicked. 
    #>
    
    Param ([string]$Button) 

    #Use this to get the name of the button
    #[System.Windows.MessageBox]::Show("$Button","Chris Titus Tech's Windows Utility","OK","Info")

    Switch -Wildcard ($Button){

        "wpf_Tab?BT" {Invoke-Tabs $Button}
        "wpf_debloatALL" {Invoke-debloatALL}
        "wpf_debloatGaming" {Invoke-debloatGaming}
        "wpf_optimizationButton" {Invoke-optimizationButton}
        "wpf_recommended" {Invoke-recommended}
        "wpf_gaming" {Invoke-gaming}
        "wpf_normal" {Invoke-normal}
        "wpf_Updatesdefault" {Invoke-UpdatesDefault}
        "wpf_FixesUpdate" {Invoke-FixesUpdate}
        "wpf_Updatesdisable" {Invoke-UpdatesDisable}
        "wpf_Updatessecurity" {Invoke-UpdatesSecurity}
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
        "wpf_FeatureInstall" {Invoke-FeatureInstall}
        "wpf_PanelAutologin" {Invoke-PanelAutologin}
        "wpf_PanelRegion" {Invoke-Configs -Panel $button}
        "wpf_DblInstall" {Invoke-installButton}
        "wpf_DblGetInstalled" {Invoke-getInstallButton}
        "wpf_DblUninstall" {Invoke-UninstallButton}
        "wpf_DblUpgrade" {Invoke-UpgradeButton}
        "wpf_DblClearPrograms" {Invoke-ClearProgramsButton}
    }
}

function Invoke-Checkbox {
    <#
    
        .DESCRIPTION
        Meant to make creating checkboxes easier. There is a section below in the gui that will assign this function to every button.
        This way you can dictate what each checkbox does from this function. 
    
        Input will be the name of the checkbox that is clicked. 
    #>

    Param ([string]$checkbox) 

    #Use this to get the name of the checkbox
    #[System.Windows.MessageBox]::Show("$checkbox","Vuk1lis's Windows Utility","OK","Info")

    Switch -Wildcard ($checkbox){
        "wpf_fastPresetButton" {Invoke-ToggleFastPreset}
        "wpf_megaPresetButton" {Invoke-ToggleMegaPreset}
        "wpf_ToggleLitePreset" {Invoke-ToggleLitePreset}
        "wpf_ToggleDevPreset" {Invoke-ToggleDevPreset}
        "wpf_ToggleGamingPreset" {Invoke-ToggleGamingPreset}
        "wpf_ToggleDarkMode" {Invoke-ToggleDarkMode}

        "wpf_ToggleBingSearchMenu" {Invoke-ToggleBingSearchMenu}
        "wpf_ToggleNumLock" {Invoke-ToggleNumLock}
        "wpf_ToggleExt" {Invoke-ToggleExt}
        "wpf_ToggleMouseAcceleration" {Invoke-ToggleMouseAcceleration}
        "wpf_TogglefIPv6" {Invoke-TogglefIPv6}
        "wpf_ToggleHiddenFiles" {Invoke-ToggleHiddenFiles}
        "wpf_ToggleSearch" {Invoke-ToggleSearch}
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

function Set-RestorePoint {
    <#
    
        .DESCRIPTION
        Purpose of this fuction is to create restore point. 
    
    #>
    
    # Check if the user has administrative privileges
    if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as an administrator."
        return
    }

    # Check if System Restore is enabled for the main drive
    try {
        # Try getting restore points to check if System Restore is enabled
        Enable-ComputerRestore -Drive "$env:SystemDrive"
    } catch {
        Write-Host "An error occurred while enabling System Restore: $_"
    }

    # Check if the SystemRestorePointCreationFrequency value exists
    $exists = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -name "SystemRestorePointCreationFrequency" -ErrorAction SilentlyContinue
    if($null -eq $exists){
        write-host 'Changing system to allow multiple restore points per day'
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value "0" -Type DWord -Force -ErrorAction Stop | Out-Null
    }

    # Get all the restore points for the current day
    $existingRestorePoints = Get-ComputerRestorePoint | Where-Object { $_.CreationTime.Date -eq (Get-Date).Date }

    # Check if there is already a restore point created today
    if ($existingRestorePoints.Count -eq 0) {
        $description = "System Restore Point created by Windows11-Optimizer-Debloater"

        Checkpoint-Computer -Description $description -RestorePointType "MODIFY_SETTINGS"
        Write-Host -ForegroundColor Green "System Restore Point Created Successfully"
    }
}

########################################### INFO ###########################################    
# HARDWARE INFO
$pcName=[System.Net.Dns]::GetHostName()
$wpf_pcName.Content="Welcome $pcName"

$cpuInfo=Get-CimInstance -ClassName CIM_Processor | Select-Object *
$wpf_cpuInfo.Content=$cpuInfo.Name

Get-CimInstance -ClassName win32_VideoController | ForEach-Object {[void]$wpf_gpuInfo.Items.Add($_.VideoProcessor)}

$ramInfo = get-wmiobject -class Win32_ComputerSystem
$ramInfoGB=[math]::Ceiling($ramInfo.TotalPhysicalMemory / 1024 / 1024 / 1024)
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
        "*Windows.DevHome*"
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
        "*Windows.DevHome*"
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

Get-Service -ErrorAction SilentlyContinue | ForEach-Object {[void]$wpf_ddlServices.Items.Add($_.Name)}
function Get-Services {
    $ServiceName=$wpf_ddlServices.SelectedItem
    $details=Get-Service -Name $ServiceName -ErrorAction SilentlyContinue | Select-Object *
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
    # Invoke restore point
    #Set-RestorePoint
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

        # remove "Widgets" button from taskbar
        Write-Host "Disable Widgets"
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0

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
    If ( $wpf_DblDisplay.IsChecked -eq $true ) {
        # https://www.tenforums.com/tutorials/6377-change-visual-effects-settings-windows-10-a.html
        # https://superuser.com/questions/1244934/reg-file-to-modify-windows-10-visual-effects
        Write-Host "Adjusted visual effects for performance"
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
    If ( $wpf_DblRemoveEdge.IsChecked -eq $true ) {
        # Standalone script by AveYo Source: https://raw.githubusercontent.com/AveYo/fox/main/Edge_Removal.bat

        curl.exe "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/edgeremoval.bat" -o $ENV:temp\\edgeremoval.bat
        Start-Process $ENV:temp\\edgeremoval.bat

        $wpf_DblRemoveEdge.IsChecked= $false
    }
    If ( $wpf_DblOneDrive.IsChecked -eq $true ) {
        Write-Host "Kill OneDrive process"
        taskkill.exe /F /IM "OneDrive.exe"
        taskkill.exe /F /IM "explorer.exe"

        Write-Host "Copy all OneDrive to Root UserProfile"
        Start-Process -FilePath robocopy -ArgumentList "$env:USERPROFILE\OneDrive $env:USERPROFILE /e /xj" -NoNewWindow -Wait

        Write-Host "Remove OneDrive"
        Start-Process -FilePath winget -ArgumentList "uninstall -e --purge --force --silent Microsoft.OneDrive " -NoNewWindow -Wait

        Write-Host "Removing OneDrive leftovers"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"

        # check if directory is empty before removing:
        If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
        }

        # On clean installs or upgrades that never had one drive removed, that sidebar entry doesn't get removed
        # For now it break windows!!!

        # Write-Host "Remove Onedrive from explorer sidebar"
        # Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
        # Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0

        Write-Host "Removing run hook for new users"
        reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
        reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
        reg unload "hku\Default"

        Write-Host "Removing startmenu entry"
        Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

        Write-Host "Removing scheduled task"
        Get-ScheduledTask -TaskPath '\\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

        # Add Shell folders restoring default locations
        Write-Host "Shell Fixing"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "AppData" -Value "$env:userprofile\AppData\Roaming" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cache" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCache" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Cookies" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\INetCookies" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Favorites" -Value "$env:userprofile\Favorites" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "History" -Value "$env:userprofile\AppData\Local\Microsoft\Windows\History" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Local AppData" -Value "$env:userprofile\AppData\Local" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Music" -Value "$env:userprofile\Music" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Video" -Value "$env:userprofile\Videos" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "NetHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Network Shortcuts" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "PrintHood" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Printer Shortcuts" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Programs" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Recent" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Recent" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "SendTo" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\SendTo" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Start Menu" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Startup" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Templates" -Value "$env:userprofile\AppData\Roaming\Microsoft\Windows\Templates" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "$env:userprofile\Downloads" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Value "$env:userprofile\Desktop" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "My Pictures" -Value "$env:userprofile\Pictures" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value "$env:userprofile\Documents" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Value "$env:userprofile\Documents" -Type ExpandString
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Value "$env:userprofile\Pictures" -Type ExpandString

        Write-Host "Restarting explorer"
        Start-Process "explorer.exe"

        Write-Host "Waiting for explorer to complete loading"
        Write-Host "Please Note - OneDrive folder may still have items in it. You must manually delete it, but all the files should already be copied to the base user folder."
        Start-Sleep 5

        $wpf_DblOneDrive.IsChecked = $false
    }
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Tweaks Are Finished"
    $Messageboxbody = ("Done")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    [System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon)
}
function Invoke-ToggleFastPreset {
    $IsChecked = $wpf_fastPresetButton.IsChecked

    $wpf_megaPresetButton.IsEnabled = !$IsChecked; $wpf_megaPresetButton.Style = $wpf_megaPresetButton.TryFindResource(('ToggleSwitchStyle' + ('Purple', 'Disabled')[$IsChecked]))

    $tabItemName = "Tab4"
    $tabItem = $psform.FindName($tabItemName)

    if ($tabItem -eq $null) {
        Write-Host "TabItem not found"
        return
    }

    $checkBoxNames = "Telemetry", "Wifi", "AH", "DeleteTempFiles", "LocTrack", "Storage", "Hiber", "DVR", "Power", "Display", "Personalize"
    $checkBoxes = $checkBoxNames | ForEach-Object { $tabItem.FindName("Dbl$_") }

    foreach ($checkBox in $checkBoxes) {
        $checkBox.IsChecked = $IsChecked
    }

    if ($IsChecked) { Write-Host "Enabling Fast Preset" -ForegroundColor Green } else { Write-Host "Disabling Fast Preset" -ForegroundColor Red }
}
function Invoke-ToggleMegaPreset {
    $IsChecked = $wpf_megaPresetButton.IsChecked

    $wpf_fastPresetButton.IsEnabled = !$IsChecked; $wpf_fastPresetButton.Style = $wpf_fastPresetButton.TryFindResource(('ToggleSwitchStyle' + ('Green', 'Disabled')[$IsChecked]))

    $tabItemName = "Tab4"
    $tabItem = $psform.FindName($tabItemName)

    if ($tabItem -eq $null) {
        Write-Host "TabItem not found"
        return
    }

    $checkBoxNames = "Telemetry", "Wifi", "AH", "DeleteTempFiles", "DiskCleanup", "LocTrack", "Storage", "Hiber", "DVR",
                    "Power", "Display", "RemoveCortana", "RightClickMenu", "DisableUAC", "Personalize"
    $checkBoxes = $checkBoxNames | ForEach-Object { $tabItem.FindName("Dbl$_") }

    foreach ($checkBox in $checkBoxes) {
        $checkBox.IsChecked = $IsChecked
    }

    if ($IsChecked) { Write-Host "Enabling Fast Preset" -ForegroundColor Green } else { Write-Host "Disabling Fast Preset" -ForegroundColor Red }
}

function Get-ToggleValue {
    param (
        [string]$Path,
        [string]$Name
    )

    return (Get-ItemProperty -Path $Path).$Name -ne 0
}
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
}
function Toggle-RegistryValue {
    param (
        [System.Windows.Controls.CheckBox]$CheckBox,
        [string]$Path,
        [string]$Name,
        [int]$TrueValue,
        [int]$FalseValue,
        [string]$EnableMessage,
        [string]$DisableMessage
    )

    $EnableMode = $CheckBox.IsChecked
    $ToggleValue = $(If ( $EnableMode ) {0} Else {1})

    If ($ToggleValue -ne 1){
        Set-RegistryValue -Path $Path -Name $Name -Value $TrueValue
        Write-Host $EnableMessage
    }
    if ($ToggleValue -ne 0){
        Set-RegistryValue -Path $Path -Name $Name -Value $FalseValue
        Write-Host $DisableMessage
    }
}

function Get-WindowsTheme {
    $themeRegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'

    $appsTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme'
    $systemTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme'

    if ($appsTheme.AppsUseLightTheme -eq 1) {
        return $false
    } else {
        return $true
    }
}
$wpf_ToggleDarkMode.IsChecked = Get-WindowsTheme
function Invoke-ToggleDarkMode {
    $themeRegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $EnableDarkMode = $wpf_ToggleDarkMode.IsChecked
    $appsTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme'
    $systemTheme = Get-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme'

    if ($appsTheme.AppsUseLightTheme -eq 1) {
        # Dark theme is currently active, switch to light theme
        Set-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme' -Value 0
        Set-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme' -Value 0
        #Write-Host "Switched to Dark Theme."
    } else {
        # Light theme is currently active, switch to dark theme
        Set-ItemProperty -Path $themeRegistryPath -Name 'AppsUseLightTheme' -Value 1
        Set-ItemProperty -Path $themeRegistryPath -Name 'SystemUsesLightTheme' -Value 1
        #Write-Host "Switched to Light Theme."
    }
    Write-Host $(If ( $EnableDarkMode ) {"Enabling Dark Mode"} Else {"Disabling Dark Mode"})
}
function Get-CheckerTweaks{
    $a = $wpf_ToggleBingSearchMenu.IsChecked = Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled'
    $b = $wpf_ToggleNumLock.IsChecked = Get-ToggleValue -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators'
    $c = $wpf_ToggleExt.IsChecked = (Get-ToggleValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt') -eq 0
    $d = $wpf_ToggleMouseAcceleration.IsChecked = (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1') -and (Get-ToggleValue -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2')
    $getValue = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden'
    $e = $wpf_ToggleHiddenFiles.IsChecked = $(If ($getValue -eq 0) {$false} Else {$true})
    $f = $wpf_ToggleSearch.IsChecked = (Get-ToggleValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode') -eq 0
    $g = $wpf_TogglefIPv6.IsChecked = $(If ((Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "True" -And $(Get-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6).Enabled -eq "False") {$true} Else {$false})

    return $a -and $b -and $c -and $d -and $e -and $f -and $g
}
Get-CheckerTweaks

function Invoke-ToggleBingSearchMenu{
    Toggle-RegistryValue -CheckBox $wpf_ToggleBingSearchMenu -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -TrueValue 1 -FalseValue 0 -EnableMessage "Enabled Bing Search" -DisableMessage "Disabling Bing Search"
}
function Invoke-ToggleNumLock{
    Toggle-RegistryValue -CheckBox $wpf_ToggleNumLock -Path 'HKCU:\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -TrueValue 2 -FalseValue 0 -EnableMessage "Enabling Numlock on startup" -DisableMessage "Disabling Numlock on startup"
}
function Invoke-ToggleExt{
    Toggle-RegistryValue -CheckBox $wpf_ToggleExt -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -TrueValue 0 -FalseValue 1 -EnableMessage "Showing file extentions" -DisableMessage "Hiding file extensions"
}
function Invoke-ToggleMouseAcceleration{    
    $EnableMode = $wpf_ToggleMouseAcceleration.IsChecked
    $ToggleValue = $(If ( $EnableMode ) {0} Else {1})
    If ($ToggleValue -ne 1){
        $Path = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $Path -Name MouseSpeed -Value 1
        Set-ItemProperty -Path $Path -Name MouseThreshold1 -Value 6
        Set-ItemProperty -Path $Path -Name MouseThreshold2 -Value 10
    }
    if ($ToggleValue -ne 0){
        $Path = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $Path -Name MouseSpeed -Value 0
        Set-ItemProperty -Path $Path -Name MouseThreshold1 -Value 0
        Set-ItemProperty -Path $Path -Name MouseThreshold2 -Value 0
    }
    Write-Host $(If ( $EnableMode ) {"Enabling Mouse Acceleration"} Else {"Disabling Mouse Acceleration"})
    }
function Invoke-TogglefIPv6{    
    $EnableMode = $wpf_TogglefIPv6.IsChecked
    $ToggleValue = $(If ( $EnableMode ) {0} Else {1})
    If ($ToggleValue -ne 1){
        Enable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
    }
    if ($ToggleValue -ne 0){
        Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
    }
    Write-Host $(If ( $EnableMode ) {"Enabling IPv6"} Else {"Disabling IPv6"})
    }
function Invoke-ToggleHiddenFiles{
    Toggle-RegistryValue -CheckBox $wpf_ToggleHiddenFiles -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -TrueValue 1 -FalseValue 0 -EnableMessage "Showing hidden files" -DisableMessage "Hide hidden files"
}
function Invoke-ToggleSearch{
    Toggle-RegistryValue -CheckBox $wpf_ToggleSearch -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode' -TrueValue 0 -FalseValue 2 -EnableMessage "Hiding search box" -DisableMessage "Showing search box"
}

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
    "wpf_PanelRegion"               {cmd /c intl.cpl}
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
########################################### INSTALL ###########################################
function Invoke-InstallMessage {
    param (
        [string]$msg
    )

    $MessageboxTitle = switch ($msg) {
        "install"  { "Installs are finished" }
        "uninstall" { "Uninstalls are finished" }
        "upgrade"   { "Upgrading are finished" }
        default     {
            Write-Warning "Unknown message type: $msg"
            return
        }
    }

    [System.Windows.MessageBox]::Show("Done", $MessageboxTitle, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
}

function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Loading" -Status "Loading..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Loading" -Status "Loading..." -SecondsRemaining 0 -Completed
}

function Invoke-ManageInstall {
    param(
            $program,
            $PackageManger,
            $PackageName,
            $manage 
        )

    if($manage -eq "Installing" -and $PackageManger -eq "pip"){
        Write-Host "Installing $name package" -ForegroundColor Green
        python -m pip install --no-input --quiet --upgrade pip
        pip install --no-input --quiet $PackageName
    }elseif($manage -eq "Installing" -and $PackageManger -eq "winget"){
        Write-Host "Installing $name package" -ForegroundColor Green
        Start-Process -FilePath winget -ArgumentList "install -e --accept-source-agreements --accept-package-agreements --silent $PackageName" -NoNewWindow -Wait
    }elseif($manage -eq "Installing" -and $PackageManger -eq "choco"){
        Write-Host "Installing $name package" -ForegroundColor Green
        Start-Process -FilePath choco -ArgumentList "install $PackageName -y" -NoNewWindow -Wait
    }

    if($manage -eq "Uninstalling" -and $PackageManger -eq "pip"){
        Write-Host "Uninstalling $name package" -ForegroundColor Red
        pip uninstall --yes --quiet $PackageName
    }elseif($manage -eq "Uninstalling" -and $PackageManger -eq "winget"){
        Write-Host "Uninstalling $name package" -ForegroundColor Green
        Start-Process -FilePath winget -ArgumentList "uninstall -e --purge --force --silent $PackageName" -NoNewWindow -Wait
    }elseif($manage -eq "Uninstalling" -and $PackageManger -eq "choco"){
        Write-Host "Uninstalling $name package" -ForegroundColor Green
        Start-Process -FilePath choco -ArgumentList "uninstall $PackageName -y" -NoNewWindow -Wait
    }

    if($manage -eq "Upgrading" -and $PackageManger -eq "pip"){
        Write-Host "Upgrading $name package" -ForegroundColor Blue
        pip install --no-input --quiet $PackageName --upgrade
    }elseif($manage -eq "Upgrading" -and $PackageManger -eq "winget"){
        Write-Host "Upgrading $name package" -ForegroundColor Green
        Start-Process -FilePath winget -ArgumentList "upgrade --silent $PackageName" -NoNewWindow -Wait
    }elseif($manage -eq "Upgrading" -and $PackageManger -eq "choco"){
        Write-Host "Upgrading $name package" -ForegroundColor Green
        Start-Process -FilePath choco -ArgumentList "upgrade $PackageName -y" -NoNewWindow -Wait
    }
}

$programs = @(
    '{
        "id": "DblInstallDockerdesktop",
        "name": "Docker Desktop",
        "winget": "Docker.DockerDesktop"
    }',
    '{
        "id": "DblInstallGit",
        "name": "Git",
        "winget": "Git.Git"
    }',
    '{
        "id": "DblInstallGitextensions",
        "name": "Git Extensions",
        "winget": "GitExtensionsTeam.GitExtensions"
    }',
    '{
        "id": "DblInstallGithubdesktop",
        "name": "GitHub Desktop",
        "winget": "GitHub.GitHubDesktop"
    }',
    '{
        "id": "DblInstallGolang",
        "name": "Go Programming Language",
        "winget": "GoLang.Go"
    }',
    '{
        "id": "DblInstallNodejs",
        "name": "Node.js",
        "winget": "OpenJS.NodeJS"
    }',
    '{
        "id": "DblInstallNodejslts",
        "name": "Node.js LTS",
        "winget": "OpenJS.NodeJS.LTS"
    }',
    '{
        "id": "DblInstallNodemanager",
        "name": "Node Version Manager (NVM)",
        "winget": "CoreyButler.NVMforWindows"
    }',
    '{
        "id": "DblInstallJava8",
        "name": "Java 8",
        "winget": "EclipseAdoptium.Temurin.8.JRE"
    }',
    '{
        "id": "DblInstallJava16",
        "name": "Java 16",
        "winget": "AdoptOpenJDK.OpenJDK.16"
    }',
    '{
        "id": "DblInstallJava18",
        "name": "Java 18",
        "winget": "EclipseAdoptium.Temurin.18.JRE"
    }',
    '{
        "id": "DblInstallOhmyposh",
        "name": "Oh My Posh",
        "winget": "JanDeDobbeleer.OhMyPosh"
    }',
    '{
        "id": "DblInstallPython3",
        "name": "Python 3",
        "winget": "Python.Python.3.12"
    }',
    '{
        "id": "DblInstallPostman",
        "name": "Postman",
        "winget": "Postman.Postman"
    }',
    '{
        "id": "DblInstallRust",
        "name": "Rust",
        "winget": "Rustlang.Rust.MSVC"
    }',
    '{
        "id": "DblInstallVisualstudio2022",
        "name": "Visual Studio 2022",
        "winget": "Microsoft.VisualStudio.2022.Community"
    }',
    '{
        "id": "DblInstallCode",
        "name": "Visual Studio Code",
        "winget": "Microsoft.VisualStudioCode"
    }',
    '{
        "id": "DblInstallDotnet3",
        "name": ".NET Core 3",
        "winget": "Microsoft.DotNet.DesktopRuntime.3_1"
    }',
    '{
        "id": "DblInstallDotnet5",
        "name": ".NET 5",
        "winget": "Microsoft.DotNet.DesktopRuntime.5"
    }',
    '{
        "id": "DblInstallDotnet6",
        "name": ".NET 6",
        "winget": "Microsoft.DotNet.DesktopRuntime.6"
    }',
    '{
        "id": "DblInstallDotnet7",
        "name": ".NET 7",
        "winget": "Microsoft.DotNet.DesktopRuntime.7"
    }',
    '{
        "id": "DblInstallPowershell",
        "name": "PowerShell",
        "winget": "Microsoft.PowerShell"
    }',
    '{
        "id": "DblInstallPowertoys",
        "name": "PowerToys",
        "winget": "Microsoft.PowerToys"
    }',
    '{
        "id": "DblInstallvc2015_64",
        "name": "Visual 2015 Redistributable (64-bit)",
        "winget": "Microsoft.VCRedist.2015+.x64"
    }',
    '{
        "id": "DblInstallvc2015_32",
        "name": "Visual 2015 Redistributable (32-bit)",
        "winget": "Microsoft.VCRedist.2015+.x86"
    }',
    '{
        "id": "DblInstallTerminal",
        "name": "Windows Terminal",
        "winget": "Microsoft.WindowsTerminal"
    }',
    '{
        "id": "DblInstallBrave",
        "name": "Brave",
        "winget": "Brave.Brave"
    }',
    '{
        "id": "DblInstallChrome",
        "name": "Google Chrome",
        "winget": "Google.Chrome"
    }',
    '{
        "id": "DblInstallChromium",
        "name": "Chromium",
        "winget": "eloston.ungoogled-chromium"
    }',
    '{
        "id": "DblInstallFirefox",
        "name": "Mozilla Firefox",
        "winget": "Mozilla.Firefox"
    }',
    '{
        "id": "DblInstallLibrewolf",
        "name": "Librewolf",
        "winget": "Librewolf.Librewolf"
    }',
    '{
        "id": "DblInstallThorium",
        "name": "Thorium",
        "winget": "Alex313031.Thorium"
    }',
    '{
        "id": "DblInstallDiscord",
        "name": "Discord",
        "winget": "Discord.Discord"
    }',
    '{
        "id": "DblInstallMatrix",
        "name": "Element (Matrix)",
        "winget": "Element.Element"
    }',
    '{
        "id": "DblInstallSkype",
        "name": "Skype",
        "winget": "Microsoft.Skype"
    }',
    '{
        "id": "DblInstallSlack",
        "name": "Slack",
        "winget": "SlackTechnologies.Slack"
    }',
    '{
        "id": "DblInstallTeams",
        "name": "Microsoft Teams",
        "winget": "Microsoft.Teams"
    }',
    '{
        "id": "DblInstallTelegram",
        "name": "Telegram",
        "winget": "Telegram.TelegramDesktop"
    }',
    '{
        "id": "DblInstallViber",
        "name": "Viber",
        "winget": "Viber.Viber"
    }',
    '{
        "id": "DblInstallZoom",
        "name": "Zoom",
        "winget": "Zoom.Zoom"
    }',
    '{
        "id": "DblInstallEaapp",
        "name": "EA Desktop App",
        "winget": "ElectronicArts.EADesktop"
    }',
    '{
        "id": "DblInstallEpicgames",
        "name": "Epic Games Store",
        "winget": "EpicGames.EpicGamesLauncher"
    }',
    '{
        "id": "DblInstallGeforcenow",
        "name": "NVIDIA GeForce NOW",
        "winget": "Nvidia.GeforceNOW"
    }',
    '{
        "id": "DblInstallGog",
        "name": "GOG Galaxy",
        "winget": "GOG.Galaxy"
    }',
    '{
        "id": "DblInstallPrism",
        "name": "Prism Launcher",
        "winget": "PrismLauncher.PrismLauncher"
    }',
    '{
        "id": "DblInstallSteam",
        "name": "Steam",
        "winget": "Valve.Steam"
    }',
    '{
        "id": "DblInstallHeroic",
        "name": "Heroic Games Launcher",
        "winget": "HeroicGamesLauncher.HeroicGamesLauncher"
    }',
    '{
        "id": "DblPythonEpicCLI",
        "name": "Legendary Epic (Python)",
        "pip": "legendary-gl"
    }',
    '{
        "id": "DblInstallUbisoft",
        "name": "Ubisoft Connect",
        "winget": "Ubisoft.Connect"
    }',
    '{
        "id": "DblInstallAudacity",
        "name": "Audacity",
        "winget": "Audacity.Audacity"
    }',
    '{
        "id": "DblInstallBlender",
        "name": "Blender",
        "winget": "BlenderFoundation.Blender"
    }',
    '{
        "id": "DblInstallFigma",
        "name": "Figma",
        "winget": "Figma.Figma"
    }',
    '{
        "id": "DblInstallCider",
        "name": "Cider",
        "winget": "CiderCollective.Cider"
    }',
    '{
        "id": "DblInstallGreenshot",
        "name": "Greenshot",
        "winget": "Greenshot.Greenshot"
    }',
    '{
        "id": "DblInstallHandbrake",
        "name": "Handbrake",
        "winget": "HandBrake.HandBrake"
    }',
    '{
        "id": "DblInstallImageglass",
        "name": "ImageGlass",
        "winget": "DuongDieuPhap.ImageGlass"
    }',
    '{
        "id": "DblInstallKodi",
        "name": "Kodi",
        "winget": "XBMCFoundation.Kodi"
    }',
    '{
        "id": "DblInstallKlite",
        "name": "K-Lite Codec Pack",
        "winget": "CodecGuide.K-LiteCodecPack.Standard"
    }',
    '{
        "id": "DblInstallObs",
        "name": "OBS Studio",
        "winget": "OBSProject.OBSStudio"
    }',
    '{
        "id": "DblChocoSpotify",
        "name": "Spotify",
        "choco": "spotify"
    }',
    '{
        "id": "DblInstallSharex",
        "name": "ShareX",
        "winget": "ShareX.ShareX"
    }',
    '{
        "id": "DblInstallVlc",
        "name": "VLC Media Player",
        "winget": "VideoLAN.VLC"
    }',
    '{
        "id": "DblInstallAnki",
        "name": "Anki",
        "winget": "Anki.Anki"
    }',
    '{
        "id": "DblInstallAdobe",
        "name": "Adobe",
        "winget": "Adobe.Acrobat.Reader.64-bit"
    }',
    '{
        "id": "DblInstallJoplin",
        "name": "Joplin",
        "winget": "Joplin.Joplin"
    }',
    '{
        "id": "DblInstallLibreoffice",
        "name": "LibreOffice",
        "winget": "TheDocumentFoundation.LibreOffice"
    }',
    '{
        "id": "DblInstallNotepadplus",
        "name": "Notepad",
        "winget": "Notepad++.Notepad++"
    }',
    '{
        "id": "DblInstallObsidian",
        "name": "Obsidian",
        "winget": "Obsidian.Obsidian"
    }',
    '{
        "id": "DblInstallOnlyoffice",
        "name": "OnlyOffice",
        "winget": "ONLYOFFICE.DesktopEditors"
    }',
    '{
        "id": "DblInstallSumatra",
        "name": "Sumatra",
        "winget": "SumatraPDF.SumatraPDF"
    }',
    '{
        "id": "DblInstallWinmerge",
        "name": "WinMerge",
        "winget": "WinMerge.WinMerge"
    }',
    '{
        "id": "DblInstall7zip",
        "name": "7-zip",
        "winget": "7zip.7zip"
    }',
    '{
        "id": "DblInstallAlacritty",
        "name": "Alacritty",
        "winget": "Alacritty.Alacritty"
    }',
    '{
        "id": "DblInstallAutohotkey",
        "name": "AutoHotkey",
        "winget": "autohotkey"
    }',
    '{
        "id": "DblInstallCpuz",
        "name": "CPU-Z",
        "winget": "CPUID.CPU-Z"
    }',
    '{
        "id": "DblInstallClasicMixer",
        "name": "ClassicVolumeMixer",
        "winget": "PopeenCom.ClassicVolumeMixer"
    }',
    '{
        "id": "DblInstallDdu",
        "name": "Display Driver Uninstaller",
        "winget": "ddu"
    }',
    '{
        "id": "DblInstallEsearch",
        "name": "Everything",
        "winget": "oidtools.Everything"
    }',
    '{
        "id": "DblInstallGpuz",
        "name": "GPU-Z",
        "winget": "TechPowerUp.GPU-Z"
    }',
    '{
        "id": "DblInstallGsudo",
        "name": "gsudo",
        "winget": "gerardog.gsudo"
    }',
    '{
        "id": "DblInstallHwinfo",
        "name": "HWiNFO",
        "winget": "REALiX.HWiNFO"
    }',
    '{
        "id": "DblInstallJdownloader",
        "name": "JDownloader",
        "winget": "AppWork.JDownloader"
    }',
    '{
        "id": "DblInstallKeepass",
        "name": "KeePassXC",
        "winget": "KeePassXCTeam.KeePassXC"
    }',
    '{
        "id": "DblInstallMsiafterburner",
        "name": "Afterburner",
        "winget": "Guru3D.Afterburner"
    }',
    '{
        "id": "DblInstallNanazip",
        "name": "NanaZip",
        "winget": "M2Team.NanaZip"
    }',
    '{
        "id": "DblInstallNvclean",
        "name": "NVCleanstall",
        "winget": "TechPowerUp.NVCleanstall"
    }',
    '{
        "id": "DblInstallOVirtualBox",
        "name": "VirtualBox",
        "winget": "Oracle.VirtualBox"
    }',
    '{
        "id": "DblInstallOpenrgb",
        "name": "OpenRGB",
        "winget": "CalcProgrammer1.OpenRGB"
    }',
    '{
        "id": "DblInstallProcesslasso",
        "name": "Process Lasso",
        "winget": "BitSum.ProcessLasso"
    }',
    '{
        "id": "DblInstallQbittorrent",
        "name": "qBittorrent",
        "winget": "qBittorrent.qBittorrent"
    }',
    '{
        "id": "DblInstallRevo",
        "name": "Revo",
        "winget": "RevoUninstaller.RevoUninstaller"
    }',
    '{
        "id": "DblInstallRufus",
        "name": "Rufus",
        "winget": "Rufus.Rufus"
    }',
    '{
        "id": "DblInstallTtaskbar",
        "name": "Ttaskbar",
        "winget": "9PF4KZ2VN4W9"
    }',
    '{
        "id": "DblInstallWinrar",
        "name": "WinRAR",
        "winget": "RARLab.WinRAR"
    }'
)

function jsonChecker {
    param(
        $name
    )

    foreach ($jsonString in $name) {
        try {
            $programObject = $jsonString | ConvertFrom-Json
            Write-Host "Successfully converted JSON: $jsonString"
        } catch {
            Write-Host "Failed to convert JSON: $jsonString"
            Write-Host "Error: $_"
        }
    }
}

function Invoke-installButton {

    foreach ($program in $programs) {
        # Convert JSON string to PowerShell object
        $appDetails = $program | ConvertFrom-Json

        # Extract application details
        $id = $appDetails.id
        $name = $appDetails.name

        $winget = $appDetails.winget

        $idPython = $($id -Like "DblPython*")
        $pipPackage = $appDetails.pip

        $idChoco = $($id -Like "DblChoco*")
        $choco = $appDetails.choco

        $checkBox = $psform.FindName("$id")
        $isChecked = $checkBox.IsChecked

        if ($isChecked -eq $true -and $idPython) {
            Invoke-ManageInstall -PackageManger "pip" -manage "Installing" -program $name -PackageName $pipPackage
        }elseif ($isChecked -eq $true -and $idChoco){
            Invoke-ManageInstall -PackageManger "choco" -manage "Installing" -program $name -PackageName $choco
        }elseif ($isChecked -eq $true){
            Invoke-ManageInstall -PackageManger "winget" -manage "Installing" -program $name -PackageName $winget
        }else {
            continue
        }
    }
    
    Invoke-InstallMessage -msg "install"
}

function Invoke-getInstallButton {
    
    # Export winget package information to a JSON file
    $wingetExportPath = Join-Path $env:TEMP "wingetPackage.json"
    Start-Process -FilePath winget -ArgumentList "export -o $wingetExportPath" -NoNewWindow -RedirectStandardOutput "$process.StandardOutput.ReadToEnd()"
    Start-Sleep (2)
    # Read and parse the JSON file
    $jsonObject = Get-Content -Raw -Path $wingetExportPath | ConvertFrom-Json

    # Export Choco packages to a text file
    $chocoExportPath = Join-Path $env:TEMP "chocoPackage.json"
    Start-Process -FilePath choco -ArgumentList "export -o $chocoExportPath" -NoNewWindow -RedirectStandardOutput "$process.StandardOutput.ReadToEnd()"
    Start-Sleep (2)
    $chocoObject = Get-Content -Path $chocoExportPath
    $xml = [xml]$chocoObject

    # Export Python packages to a text file
    pip freeze | Out-File -FilePath "$env:TEMP\pipPackage.txt"
    $PIPpackage = "$env:TEMP\PIPpackage.txt" 

    # Process winget packages and Python packages in a single loop
    foreach ($program in $programs) {
        $appDetails = $program | ConvertFrom-Json
        $id = $appDetails.id
        $checkBox = $psform.FindName($id)

        # Process winget packages
        foreach ($package in $jsonObject.Sources.Packages) {
            if ($package.PackageIdentifier -eq $appDetails.winget) {
                $checkBox.IsChecked = $true
            }
        }

        # Process Python packages
        foreach ($line in Get-Content -Path $PIPpackage) {
            $index = $line.IndexOf('=')
            $result = $line.Substring(0, $index).Trim()
            if ($result -eq $appDetails.python) {
                $checkBox.IsChecked = $true
            }
        }

        # Process Choco packages
        foreach ($package in $xml.packages.package) {
            if ($package.id -eq $appDetails.choco) {
                $checkBox.IsChecked = $true
            }
        }
    }
}

function Invoke-UninstallButton {
    foreach ($program in $programs) {
        # Convert JSON string to PowerShell object
        $appDetails = $program | ConvertFrom-Json

        # Extract application details
        $id = $appDetails.id
        $name = $appDetails.name

        $winget = $appDetails.winget

        $idPython = $($id -Like "DblPython*")
        $pipPackage = $appDetails.pip

        $idChoco = $($id -Like "DblChoco*")
        $choco = $appDetails.choco

        $checkBox = $psform.FindName("$id")
        $isChecked = $checkBox.IsChecked

        if ($isChecked -eq $true -and $idPython) {
            Invoke-ManageInstall -PackageManger "pip" -manage "Uninstalling" -program $name -PackageName $pipPackage
        }elseif ($isChecked -eq $true -and $idChoco){
            Invoke-ManageInstall -PackageManger "winget" -manage "Uninstalling" -program $name -PackageName $choco
        }elseif ($isChecked -eq $true){
            Invoke-ManageInstall -PackageManger "winget" -manage "Uninstalling" -program $name -PackageName $winget
        }else {
            continue
        }
    }
    
    Invoke-InstallMessage -msg "uninstall"
}

function Invoke-UpgradeButton {
    foreach ($program in $programs) {
        # Convert JSON string to PowerShell object
        $appDetails = $program | ConvertFrom-Json

        # Extract application details
        $id = $appDetails.id
        $name = $appDetails.name

        $winget = $appDetails.winget

        $idPython = $($id -Like "DblPython*")
        $pipPackage = $appDetails.pip

        $idChoco = $($id -Like "DblChoco*")
        $choco = $appDetails.choco

        $checkBox = $psform.FindName("$id")
        $isChecked = $checkBox.IsChecked

        if ($isChecked -eq $true -and $idPython) {
            Invoke-ManageInstall -PackageManger "pip" -manage "Upgrading" -program $name -PackageName $pipPackage
        }elseif ($isChecked -eq $true -and $idChoco){
            Invoke-ManageInstall -PackageManger "winget" -manage "Upgrading" -program $name -PackageName $choco
        }elseif ($isChecked -eq $true){
            Invoke-ManageInstall -PackageManger "winget" -manage "Upgrading" -program $name -PackageName $winget
        }else {
            continue
        }
    }
    
    Invoke-InstallMessage -msg "upgrade"
}

function Invoke-ClearProgramsButton {
    
    $presets = @($wpf_ToggleLitePreset, $wpf_ToggleDevPreset, $wpf_ToggleGamingPreset)
    $styles = @("ToggleSwitchStyleGreen", "ToggleSwitchStylePurple", "ToggleSwitchStyleBlue")

    for ($i = 0; $i -lt $presets.Count; $i++) {
        $presets[$i].IsEnabled = $true
        $presets[$i].IsChecked = $false
        $presets[$i].Style = $presets[$i].TryFindResource($styles[$i])
    }

    foreach ($program in $programs) {
        $appDetails = $program | ConvertFrom-Json
        $id = $appDetails.id
        $checkBox = $psform.FindName("$id")
        
        $checkBox.IsChecked = $IsChecked = $false
    }
    Write-Host "Selection cleared" -ForegroundColor Green
}

function Invoke-ToggleLitePreset {
    $IsChecked = $wpf_ToggleLitePreset.IsChecked

    $wpf_ToggleDevPreset.IsEnabled = !$IsChecked; $wpf_ToggleDevPreset.Style = $wpf_ToggleDevPreset.TryFindResource(('ToggleSwitchStyle' + ('Purple', 'Disabled')[$IsChecked]))
    $wpf_ToggleGamingPreset.IsEnabled = !$IsChecked; $wpf_ToggleGamingPreset.Style = $wpf_ToggleGamingPreset.TryFindResource(('ToggleSwitchStyle' + ('Blue', 'Disabled')[$IsChecked]))

    foreach ($program in $programs) {
        $appDetails = $program | ConvertFrom-Json
        $id = $appDetails.id
        $checkBox = $psform.FindName("$id")
        
        $checkBox.IsChecked = $IsChecked -and @(
            "Git", "Java8", "Ohmyposh", "Code", "Powershell", 
            "vc2015_64", "vc2015_32", "Terminal", "Thorium", 
            "Discord", "Steam", "Greenshot", "Imageglass", "Klite", 
            "Vlc", "Notepadplus", "Sumatra", "7zip", "Cpuz", 
            "ClasicMixer", "Hwinfo", "Jdownloader", "Msiafterburner", 
            "Qbittorrent", "Ttaskbar"
        ) -contains $checkBox.Name.Replace("DblInstall", "") 
    }

    if ($IsChecked) { Write-Host "Enabling Lite Preset" -ForegroundColor Green } else { Write-Host "Disabling Lite Preset" -ForegroundColor Red }
}

function Invoke-ToggleDevPreset {
    $IsChecked = $wpf_ToggleDevPreset.IsChecked

    $wpf_ToggleLitePreset.IsEnabled = !$IsChecked; $wpf_ToggleLitePreset.Style = $wpf_ToggleLitePreset.TryFindResource(('ToggleSwitchStyle' + ('Green', 'Disabled')[$IsChecked]))
    $wpf_ToggleGamingPreset.IsEnabled = !$IsChecked; $wpf_ToggleGamingPreset.Style = $wpf_ToggleGamingPreset.TryFindResource(('ToggleSwitchStyle' + ('Blue', 'Disabled')[$IsChecked]))

    foreach ($program in $programs) {
        $appDetails = $program | ConvertFrom-Json
        $id = $appDetails.id
        $checkBox = $psform.FindName("$id")

        $checkBox.IsChecked = $IsChecked -and @(
            "Githubdesktop", "Nodemanager", "Java8", "Ohmyposh",
            "Python3", "Postman", "Visualstudio2022", "Code",
            "Dotnet3", "Dotnet5", "Dotnet6", "Dotnet7",
            "Powershell", "vc2015_64", "vc2015_32", "Terminal",
            "Thorium", "Discord", "Slack", "Teams", "Zoom",
            "Steam", "Greenshot", "Imageglass", "Klite", "Vlc",
            "Notepadplus", "7zip", "Cpuz", "ClasicMixer", "Hwinfo",
            "Jdownloader", "Msiafterburner", "OVirtualBox", "Qbittorrent",
            "Ttaskbar", "Winrar", "Sumatra"
        ) -contains $checkBox.Name.Replace("DblInstall", "")

    }

    if ($IsChecked) { Write-Host "Enabling Dev Preset" -ForegroundColor Green } else { Write-Host "Disabling Dev Preset" -ForegroundColor Red }
}

function Invoke-ToggleGamingPreset {
    $IsChecked = $wpf_ToggleGamingPreset.IsChecked

    $wpf_ToggleLitePreset.IsEnabled = !$IsChecked; $wpf_ToggleLitePreset.Style = $wpf_ToggleLitePreset.TryFindResource(('ToggleSwitchStyle' + ('Green', 'Disabled')[$IsChecked]))
    $wpf_ToggleDevPreset.IsEnabled = !$IsChecked; $wpf_ToggleDevPreset.Style = $wpf_ToggleDevPreset.TryFindResource(('ToggleSwitchStyle' + ('Purple', 'Disabled')[$IsChecked]))

    foreach ($program in $programs) {
        $appDetails = $program | ConvertFrom-Json
        $id = $appDetails.id
        $checkBox = $psform.FindName("$id")

        $checkBox.IsChecked = $IsChecked -and @(
            "Git", "Dotnet3", "Dotnet5", "Dotnet6",
            "Dotnet7", "vc2015_64", "vc2015_32", "Thorium",
            "Discord", "Eaapp", "Epicgames", "Steam",
            "Ubisoft", "Greenshot", "Imageglass", "Obs",
            "Notepadplus", "Sumatra", "7zip", "Cpuz",
            "ClasicMixer", "Hwinfo", "Msiafterburner", "Qbittorrent"
        ) -contains $checkBox.Name.Replace("DblInstall", "")

    }

    if ($IsChecked) { Write-Host "Enabling Gaming Preset" -ForegroundColor Green } else { Write-Host "Disabling Gaming Preset" -ForegroundColor Red }
}

$wpf_ToggleLitePreset.Add_Click({
    Invoke-ToggleLitePreset
})
$wpf_ToggleDevPreset.Add_Click({
    Invoke-ToggleDevPreset
})
$wpf_ToggleGamingPreset.Add_Click({
    Invoke-ToggleGamingPreset
})
########################################### /INSTALL ########################################## 
Get-Author
$wpf_diskNameInfo.Add_SelectionChanged({Get-DiskInfo})
$wpf_diskName.Add_SelectionChanged({Get-DiskSize})
$wpf_ddlServices.Add_SelectionChanged({Get-Services})
$psform.ShowDialog() | out-null