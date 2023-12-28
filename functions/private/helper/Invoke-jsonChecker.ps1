function Invoke-jsonChecker {
    <#

    .SYNOPSIS
        This function checks if json object can be successfully converted into a PowerShell object
        Provides some basic error handling to report whether the conversion was successful or if an error occurred during the process
        Invoke-jsonChecker -name "applications"
    #>

    param(
        $name
    )

    $jsonfile = Get-Content ./config/$name.json | ConvertFrom-Json

    foreach ($jsonString in $jsonfile) {
        try {
            $programObject = $jsonString
            Write-Host "Successfully converted JSON: $jsonString" -ForegroundColor Green
        } catch {
            Write-Host "Failed to convert JSON: $jsonString" -ForegroundColor Red
            Write-Host "Error: $_"
        }
    }
}