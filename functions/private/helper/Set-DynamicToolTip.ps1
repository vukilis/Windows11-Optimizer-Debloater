function Invoke-SetDynamicToolTip {
    <#
    .SYNOPSIS
        Assigns Description values from config JSONs to matching WPF controls.
        Designed to run after Window.Loaded so FindName sees the full namescope.
    #>

    $missing = 0

    foreach ($ttKey in $sync.configs.tweaks.PSObject.Properties.Name) {
        $control = $psform.FindName($ttKey)
        if ($null -ne $control -and $sync.configs.tweaks.$ttKey.PSObject.Properties.Name -contains "Description") {
            $description = $sync.configs.tweaks.$ttKey.Description
            $control.ToolTip = $description
        } else {
            Write-Host "No matching control or description found for '$ttKey'." -ForegroundColor Yellow
            $missing++
        }
    }

    foreach ($ttKey in $sync.configs.configuration.PSObject.Properties.Name) {
        $control = $psform.FindName($ttKey)
        if ($null -ne $control -and $sync.configs.configuration.$ttKey.PSObject.Properties.Name -contains "Description") {
            $description = $sync.configs.configuration.$ttKey.Description
            $control.ToolTip = $description
        } else {
            Write-Host "No matching control or description found for '$ttKey'." -ForegroundColor Yellow
            $missing++
        }
    }

    if ($missing -gt 0) {
        Write-Host "Tooltip assignment complete with $missing missing control(s)." -ForegroundColor Yellow
    } else {
        Write-Host "All tooltips assigned successfully." -ForegroundColor Green
    }
}

