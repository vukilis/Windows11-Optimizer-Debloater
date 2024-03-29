function Invoke-SelectApplication {
    <#

    .SYNOPSIS
        This function select MS APPX you choose.
    #>

    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $checkedCheckboxes = $DblGetPanel.Children
    $checkedCount = 0
    foreach ($app in $checkedCheckboxes) {
        $isChecked = $app.IsChecked
        if ($isChecked -eq $true) {
            AddCustomLabel -content $app.Content -panel $DblSelectPanel -Foreground "#a69f6c" -Margin @(15, 5, 15, 4) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
            $checkedCount++
        }
    }
    $wpf_DblSelected.Content = "Selected: $checkedCount of $($matchingMsAppx.Count)"
}