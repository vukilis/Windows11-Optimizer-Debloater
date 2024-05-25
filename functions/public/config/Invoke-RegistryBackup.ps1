function Invoke-RegistryBackup {
    <#

    .SYNOPSIS
        Creating a backup registry. 
    #>

    Art -artN "
============================================================
== Backup might take some time - approximation 30 seconds ==
============================================================
" -ch DarkGreen

    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
    $FileBrowser.Title = "Save Registry Backup"
    $FileBrowser.Filter = "Registry files (*.reg)|*.reg"
    $FileBrowser.DefaultExt = "reg"
    $FileBrowser.AddExtension = $true
    $FileBrowser.InitialDirectory = [Environment]::GetFolderPath("Desktop")

    $DialogResult = $FileBrowser.ShowDialog()

    if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $FilePath = $FileBrowser.FileName
        $TempFilePath = [System.IO.Path]::GetTempFileName()
        $RegistryRoots = @("HKEY_CURRENT_USER", "HKEY_LOCAL_MACHINE", "HKEY_CURRENT_CONFIG")

        foreach ($Root in $RegistryRoots) {
            reg export $Root $TempFilePath /y
            Get-Content -Path $TempFilePath | Out-File -Append -FilePath $FilePath
        }
        Remove-Item -Path $TempFilePath

        Art -artN "
==========================================
== Backup registry created successfully ==
== Location: $FilePath ==
==========================================
" -ch DarkGreen

    Invoke-MessageBox -msg "backup"
    } else {
        Art -artN "
======================================
== Operation cancelled by the user. ==
======================================
" -ch DarkRed
    }
}