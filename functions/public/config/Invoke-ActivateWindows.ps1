function Invoke-ActivateWindows {
    <#
        .DESCRIPTION
        Run Microsoft Activation Scripts (MAS) script 
    #>
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command irm https://massgrave.dev/get | iex" -Verb RunAs
}