function Invoke-SelectApplication {
    <#

    .SYNOPSIS
        This function Select all MS APPX you choose to uninstall.
    #>

    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblSelectPanel.Children.Clear()
    $checkedCheckboxes = $DblGetPanel.Children
    $checkedCount = 0
    foreach ($app in $checkedCheckboxes) {
        $isChecked = $app.IsChecked
        if ($isChecked -eq $true) {
            AddCustomLabel -content $app.Content -panel $DblSelectPanel -Foreground "#a69f6c" -Margin @(15, 5, 15, 0) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
            $checkedCount++
        }
    }
    AddCustomLabel -content "Checked: $checkedCount of $($matchingMsAppx.Count)" -panel $DblSelectPanel -Foreground "#F4AB51" -Margin @(15, 5, 15, 0) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"
}