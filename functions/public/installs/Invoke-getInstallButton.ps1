function Invoke-getInstallButton {
    <#

    .SYNOPSIS
        This function select all installed apps
        Read installed winget, choco and pip packages  
    #>

    Write-Host "Selecting Installed applications" -ForegroundColor Green
    # Export winget package information to a JSON file
    $wingetExportPath = Join-Path $env:TEMP "wingetPackage.json"
    winget export -o $wingetExportPath
    #Start-Sleep (2)
    # Read and parse the JSON file
    $jsonObject = Get-Content -Raw -Path $wingetExportPath | ConvertFrom-Json

    # Export Choco packages to a text file
    $chocoExportPath = Join-Path $env:TEMP "chocoPackage.json"
    choco export -o $chocoExportPath
    #Start-Sleep (2)
    $chocoObject = Get-Content -Path $chocoExportPath
    $xml = [xml]$chocoObject

    # Export Python packages to a text file
    pip freeze | Out-File -FilePath "$env:TEMP\pipPackage.txt"
    $PIPpackage = "$env:TEMP\PIPpackage.txt" 

    # Process winget packages
    foreach ($package in $jsonObject.Sources.Packages) {
        $matchingProgram = Invoke-APPX | Where-Object { $_.Winget -eq $package.PackageIdentifier }

        if ($matchingProgram -ne $null) {
            $checkBox = $psform.FindName($matchingProgram.Id)
            $checkBox.IsChecked = $true
        }
    }

    # Process Python packages
    foreach ($line in Get-Content -Path $PIPpackage) {
        $index = $line.IndexOf('=')
        $result = $line.Substring(0, $index).Trim()
        $matchingProgram = Invoke-APPX | Where-Object { $_.PipPackage -eq $result }
        if ($matchingProgram -ne $null) {
            $checkBox = $psform.FindName($matchingProgram.Id)
            $checkBox.IsChecked = $true
        }
    }

    # Process Choco packages
    foreach ($package in $xml.packages.package) {
        $matchingProgram = Invoke-APPX | Where-Object { $_.Choco -eq $package.id }
        if ($matchingProgram -ne $null) {
            $checkBox = $psform.FindName($matchingProgram.Id)
            $checkBox.IsChecked = $true
        }
    }
    
}