function Invoke-getInstallButton {
    <#

    .SYNOPSIS
        This function select all installed apps
        Read installed winget, choco and pip packages  
    #>

    Write-Host "Selecting Installed applications" -ForegroundColor Green

    # Process winget packages
    try {
        $wingetExportPath = Join-Path $env:TEMP "wingetPackage.json"
        $exportResult = winget export -o $wingetExportPath 2>&1
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -Path $wingetExportPath)) {
            throw "winget export failed with exit code $LASTEXITCODE. Output: $exportResult"
        }
        $jsonObject = Get-Content -Raw -Path $wingetExportPath -ErrorAction Stop | ConvertFrom-Json

        foreach ($package in $jsonObject.Sources.Packages) {
            $matchingProgram = Invoke-APPX | Where-Object { $_.Winget -eq $package.PackageIdentifier }

            if ($matchingProgram -ne $null) {
                $checkBox = $psform.FindName($matchingProgram.Id)
                $checkBox.IsChecked = $true
            }
        }
    } catch {
        Write-Warning "Failed to process winget packages: $_"
    }

    # Process Python packages
    try {
        $pipExportPath = Join-Path $env:TEMP "pipPackage.txt"
        pip freeze | Out-File -FilePath $pipExportPath -ErrorAction Stop

        foreach ($line in Get-Content -Path $pipExportPath -ErrorAction Stop) {
            $index = $line.IndexOf('=')
            if ($index -lt 0) { continue }
            $result = $line.Substring(0, $index).Trim()
            $matchingProgram = Invoke-APPX | Where-Object { $_.PipPackage -eq $result }
            if ($matchingProgram -ne $null) {
                $checkBox = $psform.FindName($matchingProgram.Id)
                $checkBox.IsChecked = $true
            }
        }
    } catch {
        Write-Warning "Failed to process Python packages: $_"
    }

    # Process Choco packages
    try {
        $chocoExportPath = Join-Path $env:TEMP "chocoPackage.json"
        if (Get-Command -Name choco -ErrorAction SilentlyContinue) {
            choco export -o $chocoExportPath -ErrorAction Stop
            $chocoObject = Get-Content -Path $chocoExportPath -ErrorAction Stop
            $xml = [xml]$chocoObject

            foreach ($package in $xml.packages.package) {
                $matchingProgram = Invoke-APPX | Where-Object { $_.Choco -eq $package.id }
                if ($matchingProgram -ne $null) {
                    $checkBox = $psform.FindName($matchingProgram.Id)
                    $checkBox.IsChecked = $true
                }
            }
        } else {
            Write-Warning "Chocolatey is not installed. Skipping choco package detection."
        }
    } catch {
        Write-Warning "Failed to process Chocolatey packages: $_"
    }
}

