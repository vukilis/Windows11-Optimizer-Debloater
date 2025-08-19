function Invoke-MessageBox {
    <#

    .SYNOPSIS
        Handler function for [System.Windows.MessageBox]
        Invoke-MessageBox -msg "install"
    #>

    param (
        [string]$msg
    )

    $MessageboxTitle = switch ($msg) {
        "install"  { "Installs are finished" }
        "uninstall" { "Uninstalls are finished" }
        "upgrade"   { "Upgrading are finished" }
        "tweak"   { "Tweaking are finished" }
        "undotweak"   { "Undo tweaking are finished" }
        "debloat"   { "Debloating are finished" }
        "debloatError"   { "Please unselect all unchecked APPXs!" }
        "debloatInfo"   { "Please select an APPX!" }
        "updateDefault"   { "Set Updates To Default" }
        "updateSecurity"   { "Set Security Updates" }
        "updateDisabled"   { "Updates Are Disabled" }
        "updateFix"   { "Reset Windows Update" }
        "updatePause"   { "Pause Windows Update" }
        "feature"   { "All features are now installed" }
        "networkReset"   { "Stock settings loaded. Please reboot your computer" }
        "soundReset"   { "Audio Service restarted" }
        "backup"   { "Backup are finished" }
        "shortcut"   { "Shortcut is created" }
        default     {
            Write-Warning "Unknown message type: $msg"
            return
        }
    }

    [System.Windows.MessageBox]::Show("Done", $MessageboxTitle, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
}
