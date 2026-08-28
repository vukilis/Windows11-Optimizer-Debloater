function Invoke-SelectApplication {
    <#

    .SYNOPSIS
        This function select MS APPX you choose.
    #>

    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $DblGetPanel = $psform.FindName("GetDebloat")
    $checkedCheckboxes = $DblGetPanel.Children
    $checkedCount = 0
    foreach ($cb in $checkedCheckboxes) {
        if ($cb -is [System.Windows.Controls.CheckBox] -and $cb.IsChecked -eq $true) {
            AddCustomLabel -content $cb.Content -panel $DblSelectPanel -Foreground "#a69f6c" -Margin @(15, 5, 15, 4) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
            $checkedCount++
        }
    }
    $wpf_DblSelected.Content = "Selected: $checkedCount of $($checkedCheckboxes.Count)"
}

