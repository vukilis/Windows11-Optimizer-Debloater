$jsonFolderPath = "..\config"

Get-ChildItem -Path $jsonFolderPath -Filter *.json | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $fixedContent = $content -replace "'", ""
    Set-Content -Path $_.FullName -Value $fixedContent
    Write-Host "Single quotes removed from $($_.Name)."
}
