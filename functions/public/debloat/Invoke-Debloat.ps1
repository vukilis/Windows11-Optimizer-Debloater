$DblGetPanel = $psform.FindName("GetDebloat")
if ($DblGetPanel) {
    $DblGetPanel.Children.Clear()
}
$wpf_DblSelected.Content = "Selected: 0 of $($appx.Count)"

# Iterate through each AppxPackage and create a TextBlock for each
$matchingMsAppx = Invoke-MsAppxDebloat
if ($DblGetPanel) {
    foreach ($app in $matchingMsAppx) {
        AddCustomCheckBox -Id "$($app.Id)" -Name "$($app.Name)" -panel $DblGetPanel -Foreground "#a69f6c" -HorizontalAlignment "Left" -Cursor "Hand" -Margin @(15, 10, 15, 5) -FontSize 11 -FontFamily "Gadugi"
    }
}

