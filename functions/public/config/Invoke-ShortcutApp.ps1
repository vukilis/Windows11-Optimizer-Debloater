
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
            $SourceExe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
            $IRM = 'irm https://dub.sh/win11deb | iex'
            $Powershell = '-NoProfile -ExecutionPolicy Bypass'
            $ArgumentsToSourceExe = "$powershell $IRM"
            $DestinationName = "Win11Deb.lnk"
            
            $downloadUrl = "https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/dev/icon.ico"
            $destinationPath = "$env:SystempRoot\win11deb.ico"

            # Check if the file already exists
            if (-not (Test-Path -Path "$env:SystempRoot\win11deb.ico")) {
                # File does not exist, download it
                Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath
                Write-Host "File downloaded to: $destinationPath" -ForegroundColor Green
            } else {
                Write-Host "File already exists at: $destinationPath" -ForegroundColor Magenta
            }     
            $iconPath = "$env:SystempRoot\win11deb.ico"
        }
    }

    $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
    $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $FileBrowser.Filter = "Shortcut Files (*.lnk)|*.lnk"
    $FileBrowser.FileName = $DestinationName
    $DialogResult = $FileBrowser.ShowDialog()

    if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($FileBrowser.FileName)
        $Shortcut.TargetPath = $SourceExe
        $Shortcut.Arguments = $ArgumentsToSourceExe
        if ($null -ne $iconPath) {
            $shortcut.IconLocation = $iconPath
        }
        $Shortcut.Save()

        $bytes = [System.IO.File]::ReadAllBytes($($FileBrowser.FileName))
        $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes("$($FileBrowser.FileName)", $bytes)

        Art -artN "
Shortcut for $ShortcutToAdd has been saved to $($FileBrowser.FileName)
" -ch DarkGreen

    Invoke-MessageBox -msg "shortcut"
    }else {
        Art -artN "
======================================
== Operation cancelled by the user. ==
======================================
" -ch DarkRed
    }
}