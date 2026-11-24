function Set-RestorePoint {
    <#
    
        .DESCRIPTION
        Purpose of this fuction is to create restore point. 
    
    #>
    
    # Check if the user has administrative privileges
    if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as an administrator."
        return
    }

    # Check if System Restore is enabled for the main drive
    try {
        # Try getting restore points to check if System Restore is enabled
        Enable-ComputerRestore -Drive "$env:SystemDrive" -ErrorAction Stop
    } catch {
        Write-Warning "An error occurred while enabling System Restore: $_"
    }

    # Check if the SystemRestorePointCreationFrequency value exists
    $exists = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -name "SystemRestorePointCreationFrequency" -ErrorAction SilentlyContinue
    if($null -eq $exists){
        write-host 'Changing system to allow multiple restore points per day'
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value "0" -Type DWord -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-Warning "Failed to allow multiple restore points per day: $_"
        }
    }

    # Get all the restore points for the current day.
    # Get-ComputerRestorePoint returns $null when no restore point exists yet and its
    # CreationTime is a WMI/DMTF string (e.g. 20261124165202.053740-000), which cannot
    # be casted with [datetime]. Both cases throw under StrictMode and the restore point
    # was never created, so every property is checked and parsed defensively.
    $today = (Get-Date).Date
    $existingRestorePoints = @()
    foreach ($restorePoint in @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue)) {
        $creationTimeProperty = $restorePoint.PSObject.Properties['CreationTime']
        if (-not $creationTimeProperty -or -not $creationTimeProperty.Value) {
            continue
        }

        try {
            $creationDate = [System.Management.ManagementDateTimeConverter]::ToDateTime([string]$creationTimeProperty.Value)
        } catch {
            Write-Verbose "Could not parse restore point creation time '$($creationTimeProperty.Value)': $($_.Exception.Message)"
            continue
        }

        if ($creationDate.Date -eq $today) {
            $existingRestorePoints += $restorePoint
        }
    }

    # Check if there is already a restore point created today
    if ($existingRestorePoints.Count -gt 0) {
        Write-Host 'A restore point was already created today, skipping.'
        return
    }

    $description = "System Restore Point created by Windows11-Optimizer-Debloater"
    try {
        Checkpoint-Computer -Description $description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host -ForegroundColor Green "System Restore Point Created Successfully"
    } catch {
        Write-Warning "Failed to create the System Restore Point: $($_.Exception.Message)"
    }
}
