function Invoke-ResetButton {
    <#

    .SYNOPSIS
        Button to reset search filter
    #>

    $wpf_CheckboxFilter.Text = "Search"

    $matchingProgram = Invoke-APPX
    foreach ($program in $matchingProgram) {
        $id = $program.Id
        $checkBoxes = $psform.FindName("$id")

        Foreach ($CheckBox in $CheckBoxes) {
            $CheckBox.Visibility = "Visible"
            $CheckBox.isChecked = $false    
        }
    }
}