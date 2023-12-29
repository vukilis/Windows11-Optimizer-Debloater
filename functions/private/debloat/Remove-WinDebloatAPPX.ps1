function Remove-WinDebloatAPPX {
    <#
        .DESCRIPTION
        This handler function will remove any of the provided APPX names
        .EXAMPLE
        Remove-WinDebloatAPPX -Name "Microsoft.Microsoft3DViewer"
    #>
    param (
        $Name
    )

    Try{
        Write-Host "Removing $Name"
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Get-AppxPackage | Where-Object {`$_.Name -like '*$Name*'} | Remove-AppxPackage -ErrorAction SilentlyContinue" -NoNewWindow
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Get-AppxProvisionedPackage -Online | Where-Object {`$_.DisplayName -like '*$Name*'} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" -NoNewWindow -Wait
    }
    Catch [System.Exception] {
        if($psitem.Exception.Message -like "*The requested operation requires elevation*"){
            Write-Warning "Unable to uninstall $name due to a Security Exception"
        }
        Else{
            Write-Warning "Unable to uninstall $name due to unhandled exception"
            Write-Warning $psitem.Exception.StackTrace 
        }
    }
    Catch{
        Write-Warning "Unable to uninstall $name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace 
    }
}