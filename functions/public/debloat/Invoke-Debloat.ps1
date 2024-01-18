$DblGetPanel = $psform.FindName("GetDebloat")
$DblSelectPanel = $psform.FindName("SetDebloat")
AddCustomLabel -content "Checked: 0 of $($appx.Count)" -panel $DblSelectPanel -Foreground "#F4AB51" -Margin @(15, 5, 15, 0) -FontSize 14 -FontWeight "Bold" -FontFamily "Gadugi"

# Iterate through each AppxPackage and create a TextBlock for each
$matchingMsAppx = Invoke-MsAppxDebloat
foreach ($app in $matchingMsAppx) {
    #Write-Host "ID: $($app.id), Name: $($app.name)"
    AddCustomCheckBox -Id "$($app.Id)" -Name "$($app.Name)" -panel $DblGetPanel -Foreground "#a69f6c" -HorizontalAlignment "Left" -Cursor "Hand" -Margin @(15, 5, 15, 0) -FontSize 11 -FontFamily "Gadugi"
}