$DblGetPanel = $psform.FindName("GetDebloat")
$wpf_DblSelected.Content = "Selected: 0 of $($appx.Count)"

# Iterate through each AppxPackage and create a TextBlock for each
$matchingMsAppx = Invoke-MsAppxDebloat
foreach ($app in $matchingMsAppx) {
    #Write-Host "ID: $($app.id), Name: $($app.name)"
    AddCustomCheckBox -Id "$($app.Id)" -Name "$($app.Name)" -panel $DblGetPanel -Foreground "#a69f6c" -HorizontalAlignment "Left" -Cursor "Hand" -Margin @(15, 10, 15, 5) -FontSize 11 -FontFamily "Gadugi"
}