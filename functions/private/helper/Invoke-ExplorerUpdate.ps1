function Invoke-ExplorerUpdate {
    <#
    .SYNOPSIS
        Refreshes the Windows Explorer
    #>

    param (
        [string]$action = "restart"
    )

    if ($action -eq "restart") {
        # Restart the Windows Explorer
        taskkill.exe /F /IM "explorer.exe"
        Start-Process "explorer.exe"
    }
}