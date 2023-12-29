#$xamlFile="xaml\MainWindow.xaml" #uncomment for development
#$inputXAML=Get-Content -Path $xamlFile -Raw #uncomment for development
$inputXAML = (new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/dev/xaml/MainWindow.xaml") #uncomment for Production
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"', '' -replace 'x:N', "N" -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[XML]$XAML=$inputXAML

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
        "wpf_ResetButton" {Invoke-ResetButton}
        "wpf_DblChocoInstall" {Invoke-ChocoInstall}
        "wpf_DblChocoUpgrade" {Invoke-ChocoUpgrade}
        "wpf_DblChocoUninstall" {Invoke-ChocoUninstall}
        "wpf_DblWingetFix" {Invoke-FixesWinget}
        "wpf_DblMsStoreFix" {Invoke-MsStoreFix}
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

Function Get-Author {
    <#
        .SYNOPSIS
        This function will show basic information about author and app
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
https://github.com/vukilis              https://vukilis.github.io/website

Name:                                   Version:
Windows11 Optimizer&Debloater           2.0    
"@
    $coloredText = $text.ToCharArray() | ForEach-Object {
        $randomColor = Get-RandomColor
        "$randomColor$_`e[0m"
    }
    Write-Output ($coloredText -join "")
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