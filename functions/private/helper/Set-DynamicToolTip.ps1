foreach ($ttKey in $sync.configs.tweaks.PSObject.Properties.Name) {
    $control = $psform.FindName($ttKey)
    if ($null -ne $control -and $sync.configs.tweaks.$ttKey.PSObject.Properties.Name -contains "Description") {
        $description = $sync.configs.tweaks.$ttKey.Description
        $control.ToolTip = $description
        # Write-Host "Assigned ToolTip to '$ttKey': $description" -ForegroundColor Green
    }
    else {
        Write-Host "No matching control or description found for '$ttKey'." -ForegroundColor Yellow
    }
}

foreach ($ttKey in $sync.configs.configuration.PSObject.Properties.Name) {
    $control = $psform.FindName($ttKey)
    if ($null -ne $control -and $sync.configs.configuration.$ttKey.PSObject.Properties.Name -contains "Description") {
        $description = $sync.configs.configuration.$ttKey.Description
        $control.ToolTip = $description
        # Write-Host "Assigned ToolTip to '$ttKey': $description" -ForegroundColor Green
    }
    else {
        Write-Host "No matching control or description found for '$ttKey'." -ForegroundColor Yellow
    }
}