function Invoke-MsStoreFix {
    <#

    .SYNOPSIS
        Fixes Microsoft Store by re-register
    #>
    
    $store = Get-AppxPackage | Select-Object Name, PackageFullName | Where-Object Name -like *windowsstore*
    if ($store){
        Write-Host "Reinstaling windows store" -ForegroundColor Green
        Get-AppxPackage *windowsstore* | Remove-AppxPackage
        Start-Sleep 1
        Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    } else{
        Write-Host "Seems Windows Store is not installed, installing now" -ForegroundColor Magenta
        Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    }
    Invoke-MessageBox -msg "install"
}