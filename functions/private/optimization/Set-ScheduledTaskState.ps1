function Set-ScheduledTaskState {
    <#

    .SYNOPSIS
        Enables or disables a Scheduled Task using its full path.

    .DESCRIPTION
        This helper intentionally does NOT use the name Set-ScheduledTask.
        The ScheduledTasks module already exports a cmdlet with that name and,
        as soon as the module is auto-loaded (for example by the first
        Disable-ScheduledTask call), PowerShell overwrites the function with the
        module version. From that point on every call fails with
        "A parameter cannot be found that matches parameter name 'Name'".

        Disable-ScheduledTask / Enable-ScheduledTask only accept the leaf task
        name, so the full path is split into TaskPath and TaskName.

    .PARAMETER Name
        The full path to the Scheduled Task, e.g.
        "Microsoft\Windows\Application Experience\ProgramDataUpdater".

    .PARAMETER State
        The state to set the task to: Enabled or Disabled.

    .EXAMPLE
        Set-ScheduledTaskState -Name "Microsoft\Windows\Autochk\Proxy" -State "Disabled"

    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$State
    )

    $taskName = Split-Path -Path $Name -Leaf
    $taskFolder = Split-Path -Path $Name -Parent

    if ([string]::IsNullOrWhiteSpace($taskFolder)) {
        # Root-level task
        $taskPath = "\"
    } else {
        $taskPath = "\" + $taskFolder.Trim("\") + "\"
    }

    $task = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
    if (-not $task) {
        # Tasks differ between Windows builds, so a missing task is not an error
        Write-Verbose "Scheduled Task $Name was not found, skipping."
        return
    }

    if ($task.State -eq $State) {
        Write-Verbose "Scheduled Task $Name is already $State."
        return
    }

    try {
        if ($State -eq "Disabled") {
            Write-Host "Disabling Scheduled Task $Name"
            Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop | Out-Null
        } else {
            Write-Host "Enabling Scheduled Task $Name"
            Enable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop | Out-Null
        }
    } catch {
        Write-Warning "Unable to set Scheduled Task $Name to $State : $($_.Exception.Message)"
    }
}
