
function Invoke-ShortcutApp {
    <#

    .SYNOPSIS
        Creates a shortcut and prompts for a save location

    .PARAMETER ShortcutToAdd
        The name of the shortcut to add

    #>
    param($ShortcutToAdd)

        $iconPath = $null
        Switch ($ShortcutToAdd) {
        "Win11Deb" {
            $SourceExe = "$env:SystemRoot\WindowsPowerShell\v1.0\powershell.exe"
            $IRM = 'irm https://maglit.me/win11app | iex'
            $Powershell = '-ExecutionPolicy Bypass -Command "Start-Process powershell.exe -verb runas -ArgumentList'
            $ArgumentsToSourceExe = "$powershell '$IRM'"
            $DestinationName = "Win11Deb.lnk"
            
            $downloadUrl = "https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/dev/icon.ico"
            $destinationPath = "$env:SystempRoot\win11deb.ico"

            # Check if the file already exists
            if (-not (Test-Path -Path "$env:SystempRoot\win11deb.ico")) {
                # File does not exist, download it
                Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath
                Write-Host "File downloaded to: $destinationPath"
            } else {
                Write-Output "File already exists at: $destinationPath"
            }     
            $iconPath = "$env:SystempRoot\win11deb.ico"
        }
    }

    $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
    $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $FileBrowser.Filter = "Shortcut Files (*.lnk)|*.lnk"
    $FileBrowser.FileName = $DestinationName
    $FileBrowser.ShowDialog() | Out-Null

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($FileBrowser.FileName)
    $Shortcut.TargetPath = $SourceExe
    $Shortcut.Arguments = $ArgumentsToSourceExe
    if ($iconPath -ne $null) {
        $shortcut.IconLocation = $iconPath
    }
    $Shortcut.Save()

    Write-Host "Shortcut for $ShortcutToAdd has been saved to $($FileBrowser.FileName)"
}