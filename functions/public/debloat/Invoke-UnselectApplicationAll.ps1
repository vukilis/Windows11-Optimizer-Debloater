function Invoke-UnselectApplicationAll {
    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $checkedCheckboxes = $DblGetPanel.Children
    $wpf_ToggleXboxPreset.IsChecked = $false
    foreach ($app in $checkedCheckboxes) {
        $app.IsChecked = $false
    }
    $wpf_DblSelected.Content = "Selected: 0 of $($matchingMsAppx.Count)"
}