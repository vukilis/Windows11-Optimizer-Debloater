function Invoke-ActivateWindows {
    <#
        .DESCRIPTION
        Run Microsoft Activation Scripts (MAS) script 
    #>
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command irm https://get.activated.win | iex" -Verb RunAs
}