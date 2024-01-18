function Invoke-UninstallDebloat {
    $DblSelectPanel = $psform.FindName("SetDebloat")
    $DblGetPanel = $psform.FindName("GetDebloat")

    $SelectPanelCount = $DblSelectPanel.Children.Count -gt 0
    $GetPanelCount = $DblGetPanel.Children.Count -gt 0

    # Check if the DoubleSelectPanel exists and has children
    $matched = $false
    if (($DblSelectPanel -and $SelectPanelCount) -and ($DblGetPanel -and $GetPanelCount)) {
        foreach ($childSelect in $DblSelectPanel.Children) {
            if ($childSelect -is [Windows.Controls.Label]) {
                $nameFromSelect = $childSelect.Content

                foreach ($childGet in $DblGetPanel.Children) {
                    if ($childGet -is [Windows.Controls.CheckBox]) {
                        $nameFromGet = $childGet.Content
                        $isChecked = $childGet.IsChecked

                        if ($nameFromSelect -eq $nameFromGet -and $isChecked) {
                            #Write-Host "Found label select: $nameFromSelect, State: $isChecked)"
                            Remove-WinDebloatAPPX -Name $nameFromSelect
                            $matched = $true
                            break
                        }
                    }
                }
            }
        }

        if (-not $matched) {
            Write-Host "Application is unchecked and is not unselect from the list. Please unselect all unchecked APPXs!" -ForegroundColor Red
        }else {
            Invoke-UninstallTeams
        }

    } else {
        Write-Host "Please select an APPX!" -ForegroundColor Magenta
    }
    Invoke-MessageBox -msg "debloat"
}