$jsonFilePath = "..\config\*.json"

if (Test-Path $jsonFilePath) {
    $jsonContent = Get-Content -Path $jsonFilePath -Raw
    $jsonContentWithoutQuotes = $jsonContent -replace "'", ""
    $jsonContentWithoutQuotes | Set-Content -Path $jsonFilePath
    Write-Host "Single quotes removed from $jsonFilePath."
} else {
    Write-Host "File not found: $jsonFilePath"
}
