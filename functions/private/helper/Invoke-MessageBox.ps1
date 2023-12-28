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
        "debloat"   { "Debloating are finished" }
        "updateDefault"   { "Set Updates To Default" }
        "updateSecurity"   { "Set Security Updates" }
        "updateDisabled"   { "Updates Are Disabled" }
        "updateFix"   { "Reset Windows Update" }
        "feature"   { "All features are now installed" }
        default     {
            Write-Warning "Unknown message type: $msg"
            return
        }
    }

    [System.Windows.MessageBox]::Show("Done", $MessageboxTitle, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
}
