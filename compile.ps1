$OFS = "`r`n"
$scriptname = "win11deb.ps1"


if (Test-Path -Path "$($scriptname)")
{
    Remove-Item -Force "$($scriptname)"
}

Write-output '
################################################################################################################
###                                                                                                          ###
### WARNING: This file is automatically generated DO NOT modify this file directly as it will be overwritten ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-Content .\scripts\start.ps1 | Out-File ./$scriptname -Append -Encoding ascii
Get-Content .\scripts\main.ps1 | Out-File ./$scriptname -Append -Encoding ascii

Write-output '
################################################################################################################
###                                                                                                          ###
###                                         INFO: JSON CONFIGS                                               ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\config | Where-Object {$_.Extension -eq ".json"} | ForEach-Object {
    $jsonObject = (Get-Content $_.FullName) -join "`n" | ConvertFrom-Json

    $convertedArray = $jsonObject | ForEach-Object {
        $objString = @{
            'id'    = $_.id
            'name'  = $_.name
            'winget'= $_.winget
        } | ConvertTo-Json -Compress
        "'$objString'"
    }

    $convertedArrayString = "@(" + ($convertedArray -join ',' ) + ")"

    Write-Output "`$programs = $convertedArrayString" | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                        INFO: HELPER FUNCTIONS                                            ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\private\helper -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                         INFO: INFO FUNCTIONS                                             ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\public\info -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                        INFO: INSTALL FUNCTIONS                                           ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\private\installs -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}
Get-ChildItem .\functions\public\installs -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                        INFO: DEBLOAT FUNCTIONS                                           ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\private\debloat -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}
Get-ChildItem .\functions\public\debloat -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                      INFO: OPTIMIZATION FUNCTIONS                                        ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\private\optimization -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}
Get-ChildItem .\functions\public\optimization -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                          INFO: SERVICE FUNCTIONS                                         ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\public\services -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                          INFO: UPDATES FUNCTIONS                                         ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\public\updates -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                           INFO: CONFIG FUNCTIONS                                         ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\functions\public\config -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii
}

Write-output '
################################################################################################################
###                                                                                                          ###
###                                       INFO: SETUP BACKGROUND CONFIG                                      ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

Get-Content .\scripts\closure.ps1 | Out-File ./$scriptname -Append -Encoding ascii