function Get-RegistryValue {
    <#
    .SYNOPSIS
        Safely retrieves a registry value. Returns $null if not found or access denied.
    .PARAMETER Path
        Registry path
    .PARAMETER Name
        Registry value name
    #>
    
    param ($Path, $Name)
    try {
        return Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
    } catch {
        return $null
    }
}