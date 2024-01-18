function Invoke-UninstallTeams {
    <#

    .SYNOPSIS
        Remove teams
    #>
    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

    Write-Host \"Stopping Teams process...\"
    Stop-Process -Name \"*teams*\" -Force -ErrorAction SilentlyContinue

    Write-Host \"Uninstalling Teams from AppData\\Microsoft\\Teams\"
    if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
        # Uninstall app
        $proc = Start-Process $TeamsUpdateExePath \"-uninstall -s\" -PassThru
        $proc.WaitForExit()
    }

    Write-Host \"Removing Teams AppxPackage...\"
    Get-AppxPackage \"*Teams*\" | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage \"*Teams*\" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    Write-Host \"Deleting Teams directory\"
    if ([System.IO.Directory]::Exists($TeamsPath)) {
        Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
    }

    Write-Host \"Deleting Teams uninstall registry key\"
    # Uninstall from Uninstall registry key UninstallString
    $us = (Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -like '*Teams*'}).UninstallString
    if ($us.Length -gt 0) {
        $us = ($us.Replace('/I', '/uninstall ') + ' /quiet').Replace('  ', ' ')
        $FilePath = ($us.Substring(0, $us.IndexOf('.exe') + 4).Trim())
        $ProcessArgs = ($us.Substring($us.IndexOf('.exe') + 5).Trim().replace('  ', ' '))
        $proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
        $proc.WaitForExit()
    }
}