function Invoke-Filter {
    <#

    .SYNOPSIS
        Search filter for apps 
    #>
    
    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $id = $program.Id
        $filter = $wpf_CheckboxFilter.Text
        $checkBoxes = $psform.FindName("$id")

        Foreach ($CheckBox in $CheckBoxes) {
            if ($CheckBox.Content.ToLower().Contains($filter)) {
                $CheckBox.Visibility = "Visible"
                #Write-Host "Match found: $name"
            }
            elseif($CheckBox.Content.Contains($filter)){
                $CheckBox.Visibility = "Visible"
            }
            elseif($CheckBox.Content.ToUpper().Contains($filter)){
                $CheckBox.Visibility = "Visible"
            }
            else {
                $CheckBox.Visibility = "Collapsed"
            }
        }
    }
}

$wpf_CheckboxFilter.Add_TextChanged({
    Invoke-Filter
})