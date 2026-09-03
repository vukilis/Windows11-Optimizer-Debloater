function Invoke-UnselectApplicationAll {
    <#

    .SYNOPSIS
        This function Unelect all MS APPX
    #>

    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $DblGetPanel = $psform.FindName("GetDebloat")
    $wpf_ToggleXboxPreset.IsChecked = $false
    foreach ($cb in $DblGetPanel.Children) {
        if ($cb -is [System.Windows.Controls.CheckBox]) {
            $cb.IsChecked = $false
        }
    }
    $wpf_DblSelected.Content = "Selected: 0 of $($DblGetPanel.Children.Count)"
}

