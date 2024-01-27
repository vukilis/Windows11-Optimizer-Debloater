function Invoke-SelectApplicationAll {
    <#

    .SYNOPSIS
        This function select all MS APPX.
    #>

    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $checkedCheckboxes = $DblGetPanel.Children
    $checkedCount = 0
    foreach ($app in $checkedCheckboxes) {
        $isChecked = $app.IsChecked = $true
        if ($isChecked -eq $true) {
            AddCustomLabel -content $app.Content -panel $DblSelectPanel -Foreground "#a69f6c" -Margin @(15, 5, 15, 4) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
            $checkedCount++
        }
    }
    $wpf_DblSelected.Content = "Selected: $checkedCount of $($matchingMsAppx.Count)"
}