function AddCustomLabel {
    param (
        [string]$content,
        [System.Windows.Controls.Panel]$panel,
        [string]$Foreground,
        [array]$Margin,
        [int]$fontSize,
        [string]$fontWeight,
        [string]$fontFamily
    )

    $label = New-Object Windows.Controls.Label
    $label.Content = $content
    $label.Foreground = $Foreground
    $label.Margin = New-Object Windows.Thickness $Margin[0], $Margin[1], $Margin[2], $Margin[3]
    $label.FontSize = $fontSize
    $label.FontWeight = $fontWeight
    $label.FontFamily = New-Object Windows.Media.FontFamily($fontFamily)
    $panel.Children.Add($label) | Out-Null
}


# $label = New-Object Windows.Controls.Label
# $label.Content = $content
# $label.Foreground = "#a69f6c"
# $label.Margin = New-Object Windows.Thickness(15, 5, 15, 0)
# $label.FontSize = 14
# $label.FontWeight = "Bold"
# $label.FontFamily = New-Object Windows.Media.FontFamily("Gadugi")
# $panel.Children.Add($label) | Out-Null