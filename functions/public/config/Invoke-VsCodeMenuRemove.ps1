function Invoke-VsCodeMenuRemove {
    <#
    .SYNOPSIS
        Removes "Open with Code" from right-click context menu
        (files + folders + folder background).
    .NOTES
        Requires admin because it touches HKCR.
    #>

    $keys = @(
        "HKCR\*\shell\VSCode",
        "HKCR\Directory\shell\VSCode",
        "HKCR\Directory\Background\shell\VSCode"
    )

    foreach ($key in $keys) {
        Start-Process reg.exe -ArgumentList "delete `"$key`" /f" -Verb RunAs -Wait
    }

    Write-Host "✅ VS Code context menu removed!" -ForegroundColor Green
}