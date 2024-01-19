function AddCustomCheckBox {
    param (
        [string]$Id,
        [string]$Name,
        [System.Windows.Controls.Panel]$panel,
        [string]$Foreground,
        [string]$HorizontalAlignment,
        [System.Windows.Input.Cursor]$Cursor,
        [array]$Margin,
        [int]$FontSize,
        [string]$FontFamily
    )

    $cbox = New-Object Windows.Controls.CheckBox
    $cbox.Name = $Id
    $cbox.Content = $Name
    $cbox.Foreground = $Foreground
    $cbox.HorizontalAlignment = $HorizontalAlignment
    $cbox.Cursor = $Cursor
    $cbox.Margin = New-Object Windows.Thickness $Margin[0], $Margin[1], $Margin[2], $Margin[3]
    $cbox.FontSize = $FontSize
    $cbox.FontFamily = New-Object Windows.Media.FontFamily("$FontFamily")

    $scaleTransform = New-Object Windows.Media.ScaleTransform
    $scaleTransform.ScaleX = 1.5
    $scaleTransform.ScaleY = 1.5
    $cbox.LayoutTransform = $scaleTransform

    $panel.Children.Add($cbox) | Out-Null
}


# $cbox = New-Object Windows.Controls.CheckBox
# $cbox.Name = $app.Id
# $cbox.Content = $app.Name
# $cbox.Foreground = "#a69f6c"
# $cbox.HorizontalAlignment = "Left"
# $cbox.Cursor = "Hand"
# $cbox.Margin = New-Object Windows.Thickness(15, 5, 15, 5)
# $cbox.FontSize = 11
# $cbox.FontFamily = New-Object Windows.Media.FontFamily("Gadugi")