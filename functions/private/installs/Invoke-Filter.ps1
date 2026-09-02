function Invoke-Filter {
    <#

    .SYNOPSIS
        Search filter for apps 
    #>
    
    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $id = $program.Id
        $filter = $wpf_CheckboxFilter.Text
        $checkBox = $psform.FindName("$id")
        if (-not $checkBox -and $script:DynamicAppCheckBoxes.ContainsKey($id)) {
            $checkBox = $script:DynamicAppCheckBoxes[$id]
        }

        if ($checkBox) {
            if ($checkBox.Content.ToLower().Contains($filter)) {
                $checkBox.Visibility = "Visible"
            }
            elseif($checkBox.Content.Contains($filter)){
                $checkBox.Visibility = "Visible"
            }
            elseif($checkBox.Content.ToUpper().Contains($filter)){
                $checkBox.Visibility = "Visible"
            }
            else {
                $checkBox.Visibility = "Collapsed"
            }
        }
    }
}

$wpf_CheckboxFilter.Add_TextChanged({
    Invoke-Filter
})

