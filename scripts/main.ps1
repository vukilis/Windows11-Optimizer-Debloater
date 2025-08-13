$xamlFile="C:\Users\vukilis\Desktop\Windows11-Optimizer-Debloater\xaml\MainWindow.xaml" #uncomment for development
$inputXAML=Get-Content -Path $xamlFile -Raw #uncomment for development
# $inputXAML = (new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/xaml/MainWindow.xaml") #uncomment for Production
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"', '' -replace 'x:N', "N" -replace '^<Win.*', '<Window'

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[XML]$XAML=$inputXAML

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

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

$wpf_AppVersion.Content = "Version: 3.1 - 03.08.2025"

function Invoke-CloseButton {
    <#
    .SYNOPSIS
        Close application

    .PARAMETER Button
    #>

    $psform.Close()
    Write-Host "Goodbye! :)" -ForegroundColor Red
}
function Invoke-MinButton {
    <#
    .SYNOPSIS
        Minimize application

    .PARAMETER Button
    #>

    $psform.WindowState = 'Minimized'
    #Write-Host "Minimize!"
}
function Invoke-MaxButton {
    <#
    .SYNOPSIS
        Maximize application
    #>

    if ($psform.WindowState -eq 'Normal')
    {
        $psform.WindowState = 'Maximized'
        $maxMargin = New-Object Windows.Thickness -ArgumentList 5, 5, 5, 5
        $wpf_MainGrid.Margin = $maxMargin
    }
    else
    {
        $psform.WindowState = 'Normal'
        $maxMargin = New-Object Windows.Thickness -ArgumentList 0, 0, 0, 0
        $wpf_MainGrid.Margin = $maxMargin
    }
}

function Invoke-BuyMeACoffee {
    <#
    .SYNOPSIS
        Open BuyMeACoffe link

    .PARAMETER Button
    #>

    Start-Process "https://buymeacoffee.com/vukilis"
}

function Invoke-BuyMeAKofi {
    <#
    .SYNOPSIS
        Open BuyMeAKofi link

    .PARAMETER Button
    #>

    Start-Process "https://ko-fi.com/vukilis"
}

$dragging = $false
$psform.Add_MouseLeftButtonDown({
    $dragging = $true
    $psform.DragMove()
})

$psform.Add_MouseLeftButtonUp({
    $dragging = $false
})

$psform.Add_MouseMove({
    if ($dragging) {
        $screenHeight = [Windows.SystemParameters]::PrimaryScreenHeight
        $mousePosition = [Windows.Forms.Cursor]::Position

        $maximizeThreshold = 24

        if ($mousePosition.Y -lt $maximizeThreshold) {
            $psform.WindowState = 'Maximized'
            $maxMargin = New-Object Windows.Thickness -ArgumentList 5, 5, 5, 5
            $wpf_MainGrid.Margin = $maxMargin
        } 
    }
})

function Maximize-Window {
    <#
    .SYNOPSIS
        Maximize application handler
    #>
    if ($psform.WindowState -eq 'Normal')
    {
        $psform.WindowState = 'Maximized'
        $maxMargin = New-Object Windows.Thickness -ArgumentList 5, 5, 5, 5
        $wpf_MainGrid.Margin = $maxMargin
    }
    else
    {
        $psform.WindowState = 'Normal'
        $maxMargin = New-Object Windows.Thickness -ArgumentList 0, 0, 0, 0
        $wpf_MainGrid.Margin = $maxMargin
    }
}
function Handle-DoubleLeftClick {
    Write-Host "Double Left Clicked!"
}
$doubleLeftClickEvent = [System.Windows.Input.MouseButtonEventHandler]{
    <#
    .SYNOPSIS
        Maximize application when double right click 
    #>
    param(
        [object]$sender,
        [System.Windows.Input.MouseButtonEventArgs]$e
    )

    if ($e.ChangedButton -eq [System.Windows.Input.MouseButton]::Left -and $e.ClickCount -eq 2) {
        Maximize-Window
        #Handle-DoubleLeftClick
    }
}
$wpf_ControlPanel.Add_MouseLeftButtonDown($doubleLeftClickEvent)
$wpf_DockerPanel.Add_MouseLeftButtonDown($doubleLeftClickEvent)

function Invoke-AboutButton {
    <#
        .DESCRIPTION
        This function show and hide about page.
    #>
    $AboutButton = $psform.FindName("AboutButton")
    $aboutGrid = $psform.FindName("AboutGrid")
    
        if ($AboutButton.IsChecked) {
            $aboutGrid.Visibility = "Visible"
            $animation = New-Object Windows.Media.Animation.DoubleAnimation
            $animation.From = 0
            $animation.To = 607.663333333333
            $animation.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(0.5))
            $aboutGrid.BeginAnimation([Windows.FrameworkElement]::WidthProperty, $animation)
        } else {
            $animation = New-Object Windows.Media.Animation.DoubleAnimation
            $animation.From = 607.663333333333
            $animation.To = 0
            $animation.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(0.5))
            $aboutGrid.BeginAnimation([Windows.FrameworkElement]::WidthProperty, $animation)
            # $aboutGrid.Visibility = "Collapsed"
        }
}


$radioButtons = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "RadioButton"}
foreach ($radioButton in $radioButtons){
    $radioButton.value.Add_Click({
        [System.Object]$Sender = $args[0]
        Invoke-Tabs "wpf_$($Sender.name)"
    })
}

$buttons = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "Button"}
foreach ($button in $buttons){
    $button.value.Add_Click({
        [System.Object]$Sender = $args[0]
        Invoke-Button "wpf_$($Sender.name)"
    })
}

$toggleButtons = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "ToggleButton"}
foreach ($btn in $toggleButtons) {
    $btn.Value.Add_Click({
        $Sender = $args[0]
        Invoke-ToggleButtons -toggle "wpf_$($Sender.Name)" -isChecked ([bool]$Sender.IsChecked)
    })
}

$checkbox = get-variable | Where-Object {$psitem.name -like "wpf_*" -and $psitem.value -ne $null -and $psitem.value.GetType().name -eq "CheckBox"}
foreach ($box in $checkbox){
    $box.value.Add_Click({
        [System.Object]$Sender = $args[0]
        Invoke-Checkbox "wpf_$($Sender.name)"
    })
}

# Load tweaks.json
$tweaksJsonPath = ".\config\tweaks.json"
$tweaks = Get-Content $tweaksJsonPath -Raw | ConvertFrom-Json

function Invoke-ToggleButtons {
    Param ([string]$ToggleButton, [bool]$isChecked)

    switch -Wildcard ($ToggleButton) {
        # Static / hard-coded buttons
        "wpf_AboutButton" { Invoke-AboutButton }
        "wpf_SettingsButton" { Invoke-SettingsButton }

        # Dynamic toggle buttons from JSON
        default {
            # Strip off "wpf_" prefix for JSON lookup
            $toggleName = $ToggleButton -replace '^wpf_', ''

            if ($tweaks.PSObject.Properties.Name -contains $toggleName) {
                $toggleEntry = $tweaks.$toggleName

                foreach ($regEntry in $toggleEntry.registry) {
                    $path = $regEntry.Path
                    $name = $regEntry.Name
                    $type = $regEntry.Type

                    if ($isChecked) {
                        $valueToSet = $regEntry.Value
                    } else {
                        $valueToSet = $regEntry.OriginalValue
                    }

                    # Write-Host "Setting registry $path\$name to $valueToSet"

                    try {
                        Set-RegistryValue -Path $path -Name $name -Type $type -Value $valueToSet

                    } catch {
                        # Write-Warning "Failed to set registry ${path}\${name}: $_"
                    }
                }
            }
            else {
                Write-Warning "No toggle matched for '$toggle'"
            }
        }
    }
}



# function Invoke-ToggleButtons {
#     Param (
#         [string]$toggle,
#         [bool]$isChecked
#     ) 

#     # Write-Host "Invoke-Toggle called with isChecked = '$isChecked'"

#     $toggleName = $toggle -replace '^wpf_', ''

#     if ($tweaks.PSObject.Properties.Name -contains $toggleName) {
#         $toggleEntry = $tweaks.$toggleName

#         foreach ($regEntry in $toggleEntry.registry) {
#             $path = $regEntry.Path
#             $name = $regEntry.Name
#             $type = $regEntry.Type

#             if ($isChecked) {
#                 $valueToSet = $regEntry.Value
#             } else {
#                 $valueToSet = $regEntry.OriginalValue
#             }

#             # Write-Host "Setting registry $path\$name to $valueToSet"

#             try {
#                 Set-RegistryValue -Path $path -Name $name -Type $type -Value $valueToSet -ErrorAction Stop

#             } catch {
#                 Write-Warning "Failed to set registry ${path}\${name}: $_"
#             }
#         }
#     }
#     else {
#         Write-Warning "No toggle matched for '$toggle'"
#     }
# }

# function Invoke-ToggleButtons {

#     <#
    
#         .DESCRIPTION
#         Meant to make creating ToggleButtons easier. There is a section below in the gui that will assign this function to every ToggleButton.
#         This way you can dictate what each ToggleButton does from this function. 
    
#         Input will be the name of the ToggleButton that is clicked. 
#     #>
    
#     Param ([string]$ToggleButton) 

#     Switch -Wildcard ($ToggleButton){
#         "wpf_AboutButton" {Invoke-AboutButton}
#     }
# }
function Invoke-Button {

    <#
    
        .DESCRIPTION
        Meant to make creating buttons easier. There is a section below in the gui that will assign this function to every button.
        This way you can dictate what each button does from this function. 
    
        Input will be the name of the button that is clicked. 
    #>
    
    Param ([string]$Button) 

    Switch -Wildcard ($Button){

        "wpf_Tab?BT" {Invoke-Tabs $Button}
        "wpf_CloseButton" {Invoke-CloseButton}
        "wpf_MinButton" {Invoke-MinButton}
        "wpf_MaxButton" {Invoke-MaxButton}
        "wpf_buymeacoffee" {Invoke-BuyMeACoffee}
        "wpf_buymeakofi" {Invoke-BuyMeAKofi}
        "wpf_SelectDebloat" {Invoke-SelectApplication}
        "wpf_SelectDebloatAll" {Invoke-SelectApplicationAll}
        "wpf_UnselectDebloatAll" {Invoke-UnselectApplicationAll}
        "wpf_UninstallDebloat" {Invoke-UninstallDebloat}
        # "wpf_debloatALL" {Invoke-debloatALL}
        # "wpf_debloatGaming" {Invoke-debloatGaming}
        "wpf_optimizationButton" {Invoke-optimizationButton}
        "wpf_recommended" {Invoke-recommended}
        "wpf_gaming" {Invoke-gaming}
        "wpf_normal" {Invoke-normal}
        "wpf_Updatesdefault" {Invoke-UpdatesDefault}
        "wpf_PauseUpdate" {Invoke-PauseUpdate}
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
        "wpf_ResetButton" {Invoke-ResetButton}
        "wpf_DblChocoInstall" {Invoke-ChocoInstall}
        "wpf_DblChocoUpgrade" {Invoke-ChocoUpgrade}
        "wpf_DblChocoUninstall" {Invoke-ChocoUninstall}
        "wpf_DblWingetFix" {Invoke-FixesWinget}
        "wpf_DblMsStoreFix" {Invoke-MsStoreFix}
        "wpf_ShortcutApp" {Invoke-ShortcutApp -ShortcutToAdd "Win11Deb"}
        "wpf_FixesNetwork" {Invoke-FixesNetwork}
        "wpf_FixesSound" {Invoke-FixesSound}
        "wpf_RegistryBackup" {Invoke-RegistryBackup}
        "wpf_WingetConfig" {Set-WingetConfig}
        "wpf_FixesADB" {Invoke-FixADB}
        "wpf_ActivateWindows" {Invoke-ActivateWindows}
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

    Switch -Wildcard ($checkbox){
        "wpf_ToggleXboxPreset" {Invoke-ToggleXboxPreseta}
        "wpf_fastPresetButton" {Invoke-ToggleFastPreset}
        "wpf_megaPresetButton" {Invoke-ToggleMegaPreset}
        "wpf_ToggleLitePreset" {Invoke-ToggleLitePreset}
        "wpf_ToggleDevPreset" {Invoke-ToggleDevPreset}
        "wpf_ToggleGamingPreset" {Invoke-ToggleGamingPreset}
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

    $TabSearchName = "Tab2"
    $TabSearchItem = $psform.FindName($TabSearchName)

    0..($Tabs.Count -1 ) | ForEach-Object {
        
        if ($x -eq $psitem){
            $TabNav.value.Items[$psitem].IsSelected = $true
        }
        else{
            $TabNav.value.Items[$psitem].IsSelected = $false
        }
    }

    $isVisible = if ($TabSearchItem.isSelected) {"Visible"} else {"Collapsed"}; $wpf_CheckboxFilter.Visibility = $isVisible; $wpf_ResetButton.Visibility = $isVisible
}
Invoke-Tabs "wpf_Tab1BT"

Function Get-Author7 {
    <#
        .SYNOPSIS
        This function will show basic information about author and app
        This is for powershell v7.1+
    #>
    
    #Clear-Host
    $colors = @("`e[38;5;200m", "`e[38;5;51m", "`e[38;5;98m")

    function Get-RandomColor {
        Get-Random -InputObject $colors
    }

    $text = @"
           __      __          _      __   _   _       
           \ \    / /         | |    /_ | | | (_)      
            \ \  / /   _   _  | | __  | | | |  _   ___ 
             \ \/ /   | | | | | |/ /  | | | | | | / __|
              \  /    | |_| | |   <   | | | | | | \__ \
               \/      \__,_| |_|\_\  |_| |_| |_| |___/
        
GitHub:                                 Website:
https://github.com/vukilis              https://vukilis.com

Name:                                   Version:
Windows11 Optimizer&Debloater           3.1    
"@
    $coloredText = $text.ToCharArray() | ForEach-Object {
        $randomColor = Get-RandomColor
        "$randomColor$_`e[0m"
    }
    Write-Output ($coloredText -join "")
    Write-Host "`n"
}

Function Get-Author5 {
    <#
        .SYNOPSIS
        This function will show basic information about author and app
        This is for powershell v5.1
    #>

    Clear-Host
    $colors = @("Red", "Cyan", "Magenta")

    function Get-RandomColor {
        Get-Random -InputObject $colors
    }

    $text = @"
           __      __          _      __   _   _       
           \ \    / /         | |    /_ | | | (_)      
            \ \  / /   _   _  | | __  | | | |  _   ___ 
             \ \/ /   | | | | | |/ /  | | | | | | / __|
              \  /    | |_| | |   <   | | | | | | \__ \
               \/      \__,_| |_|\_\  |_| |_| |_| |___/
        
GitHub:                                 Website:
https://github.com/vukilis              https://vukilis.com

Name:                                   Version:
Windows11 Optimizer&Debloater           3.1    
"@

    $coloredText = $text.ToCharArray() | ForEach-Object {
        $randomColor = Get-RandomColor
        Write-Host $_ -ForegroundColor $randomColor -NoNewline
    }

    Write-Host "`n"
}


function Art {
    <#
        .SYNOPSIS
        This function will show tweak message in console in different colors
    #>

    param (
        [string]$artN,
        [string]$ch = "White"
    )

    $artN | ForEach-Object {
        Write-Host $_ -NoNewline -ForegroundColor $ch
    }

    Write-Host "`n"
}

### Get all variables from form
# Get-Variable wpf_*
# Function to download a file

$downloadUrl = "https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/logo.png"
$destinationPath = Join-Path $env:TEMP "win11deb_logo.png"

# Check if the file already exists
if (-not (Test-Path $destinationPath)) {
    # File does not exist, download it
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($downloadUrl, $destinationPath)
    Write-Host "File downloaded to: $destinationPath"
} else {
    Write-Output "File already exists at: $destinationPath"
}