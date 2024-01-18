function Invoke-UnselectApplicationAll {
    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $checkedCheckboxes = $DblGetPanel.Children
    $wpf_ToggleXboxPreset.IsChecked = $false
    foreach ($app in $checkedCheckboxes) {
        $app.IsChecked = $false
    }
    AddCustomLabel -content "Checked: 0 of $($matchingMsAppx.Count)" -panel $DblSelectPanel -Foreground "#F4AB51" -Margin @(15, 5, 15, 0) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
}