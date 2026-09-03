function Invoke-Filter {
    <#

    .SYNOPSIS
        Search filter for apps 
    #>
    
    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $id = $program.Id
        $filter = $wpf_CheckboxFilter.Text
        $checkBox = $script:DynamicAppCheckBoxes[$id]

        if ($checkBox) {
            if ([string]::IsNullOrWhiteSpace($filter)) {
                $checkBox.Visibility = "Visible"
            }
            elseif ($checkBox.Content.ToString().IndexOf($filter, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $checkBox.Visibility = "Visible"
            }
            else {
                $checkBox.Visibility = "Collapsed"
            }
        }
    }

    $searchIconPath = $wpf_SearchIconPath
    if ($searchIconPath) {
        if ([string]::IsNullOrWhiteSpace($filter)) {
            $searchIconPath.Data = [System.Windows.Media.Geometry]::Parse("M11.5 2C6.81 2 3 5.81 3 10.5c0 2.05.74 3.93 1.97 5.39l-2.28 2.28c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l2.28-2.28C7.57 18.26 9.45 19 11.5 19 16.19 19 20 15.19 20 10.5S16.19 2 11.5 2zm0 2c3.59 0 6.5 2.91 6.5 6.5s-2.91 6.5-6.5 6.5S5 14.09 5 10.5 7.91 4 11.5 4z")
            $searchIconPath.ToolTip = "Search"
        } else {
            $searchIconPath.Data = [System.Windows.Media.Geometry]::Parse("M24.17 21.34L35.51 32.68 24.17 44.02 26.99 46.84 38.33 35.5 49.67 46.84 52.49 44.02 41.15 32.68 52.49 21.34 49.67 18.52 38.33 29.86 26.99 18.52z")
            $searchIconPath.ToolTip = "Reset Search"
        }
    }
}

$wpf_CheckboxFilter.Add_TextChanged({
    Invoke-Filter
})

$wpf_SearchIconPath.Add_MouseLeftButtonDown({
    if (-not [string]::IsNullOrWhiteSpace($wpf_CheckboxFilter.Text)) {
        $wpf_CheckboxFilter.Text = ""
        Invoke-Filter
    }
})

