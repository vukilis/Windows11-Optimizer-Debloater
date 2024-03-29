function Invoke-ToggleXboxPreseta {
    <#

    .SYNOPSIS
        XBOX preset to help when debloating.
    .DESCRIPTION
        This will remove ALL Microsoft store apps other than the essentials to make winget and xbox work. 
        Games installed by MS Store ARE NOT INCLUDED!
    #>

    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $checkedCheckboxes = $DblGetPanel.Children
    $state = $wpf_ToggleXboxPreset.IsChecked
    
    $xboxApps = @(
        "Microsoft.BingWeather", "Microsoft.GamingServices", "Microsoft.XboxApp", "Microsoft.Xbox.TCUI",
        "Microsoft.XboxGameOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxGameCallableUI", "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.XboxIdentityProvider", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.MixedReality.Portal"
    )

    $checkedCount = 0
    foreach ($app in $checkedCheckboxes) {
        if ($app -is [Windows.Controls.CheckBox]){
            $isChecked = $app.IsChecked = $false

            if ($isChecked -eq $false -and $state -and $xboxApps -notcontains $app.Content) {
                AddCustomLabel -content $app.Content -panel $DblSelectPanel -Foreground "#a69f6c" -Margin @(15, 5, 15, 4) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
                $app.IsChecked = $true
                $checkedCount++
            } else {
                $app.IsChecked = $false
            }
        }
    }
    $wpf_DblSelected.Content = "Selected: $checkedCount of $($matchingMsAppx.Count)"
}