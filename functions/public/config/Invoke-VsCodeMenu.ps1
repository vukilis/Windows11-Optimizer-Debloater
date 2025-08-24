function Invoke-VsCodeMenu {
    <#
    .SYNOPSIS
        Adds "Open with Code" to right-click menu (files + folders + background).
        Uses $env:LOCALAPPDATA dynamically.
    #>

    $codePath = Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\Code.exe"

    if (-not (Test-Path $codePath)) {
        Write-Warning "❌ VS Code not found at: $codePath"
        return
    }

    # Convert to .reg-safe format (double backslashes)
    $codePathReg = $codePath -replace '\\', '\\\\'

    $regContent = @"
Windows Registry Editor Version 5.00

; Add "Open with Code" for folder background
[HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode]
@="Open with Code"
"Icon"="\"$codePathReg\""

[HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode\command]
@="\"$codePathReg\" \"%V\""

; Add "Open with Code" for files
[HKEY_CLASSES_ROOT\*\shell\VSCode]
@="Open with Code"
"Icon"="\"$codePathReg\""

[HKEY_CLASSES_ROOT\*\shell\VSCode\command]
@="\"$codePathReg\" \"%1\""
"@

    $tempFile = [IO.Path]::GetTempFileName() + ".reg"
    Set-Content -Path $tempFile -Value $regContent -Encoding ASCII

    # Import registry file (requires admin for HKCR)
    Start-Process reg.exe -ArgumentList "import `"$tempFile`"" -Verb RunAs -Wait

    Remove-Item $tempFile -Force
    Write-Host "VS Code context menu added!" -ForegroundColor Green
}