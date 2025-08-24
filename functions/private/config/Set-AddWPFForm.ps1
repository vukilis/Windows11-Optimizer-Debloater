$global:FeatureControls = @{}

foreach ($featureName in $sync.configs.feature.PSObject.Properties.Name) {
    $feature = $sync.configs.feature.$featureName

    if (-not $feature.Category) { continue }

    $parentPanel = $psform.FindName($feature.Category)
    if (-not $parentPanel) {
        # Write-Warning "Category '$($feature.Category)' not found in XAML"
        continue
    }

    switch ($feature.Type) {
        "CheckBox" {
            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Name = $featureName
            $cb.Content = $feature.Content
            $cb.ToolTip = $feature.Description
            $cb.Margin = "8,5,0,0"
            $cb.FontSize = 11
            $cb.FontFamily = "Gadugi"
            $cb.Foreground = "#a69f6c"
            $cb.Cursor = "Hand"
            
            $transform = New-Object Windows.Media.ScaleTransform 1.5, 1.5
            $cb.LayoutTransform = $transform

            $global:FeatureControls[$featureName] = $cb

            $parentPanel.Children.Add($cb) | Out-Null
        }
        "Button" {
            $btn = New-Object System.Windows.Controls.Button
            $btn.Name = $featureName
            $btn.Content = $feature.Content
            $btn.ToolTip = $feature.Description
            $btn.Margin = "0,10,0,0"
            $btn.Padding = "10"
            $btn.Height = 30
            $btn.Width = 190
            $btn.Cursor = "Hand"
            $btn.FontSize = 16
            $btn.FontFamily = "Helvetica"
            
            $style = $psform.FindResource("ButtonStyle")
            if ($style) {
                $btn.Style = $style
            }

            $btn.Add_Click({
                Invoke-FeatureInstall
            })

            $parentPanel.Children.Add($btn) | Out-Null
        }
    }   
}