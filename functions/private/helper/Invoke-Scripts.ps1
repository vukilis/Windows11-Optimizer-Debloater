function Invoke-Scripts {
    <#
    .SYNOPSIS
        Invokes the provided script or scriptblock. Intended for tweaks that can't be handled with the other functions.

    .PARAMETER Name
        The name of the script being invoked.

    .PARAMETER Script
        The script content as a string or scriptblock.

    .EXAMPLE
        Invoke-Scripts -Name "Hello World" -Script {"Write-Output 'Hello World'"}
        Invoke-Scripts -Name "Hello World" -Script "Write-Output 'Hello World'"
    #>
    param (
        [string]$Name,
        [Parameter(Mandatory)]
        $Script
    )

    try {
        #Write-Host "Running script for $Name"

        # Convert string to scriptblock if needed
        if ($Script -is [string]) {
            $ScriptBlock = [scriptblock]::Create($Script)
        } elseif ($Script -is [scriptblock]) {
            $ScriptBlock = $Script
        } else {
            throw "Unsupported script type: $($Script.GetType().FullName)"
        }

        Invoke-Command $ScriptBlock -ErrorAction Stop
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Warning "The specified command was not found."
        Write-Warning $PSItem.Exception.message
    } catch [System.Management.Automation.RuntimeException] {
        Write-Warning "A runtime exception occurred."
        Write-Warning $PSItem.Exception.message
    } catch [System.Security.SecurityException] {
        Write-Warning "A security exception occurred."
        Write-Warning $PSItem.Exception.message
    } catch [System.UnauthorizedAccessException] {
        Write-Warning "Access denied. You do not have permission to perform this operation."
        Write-Warning $PSItem.Exception.message
    } catch {
        # Generic catch block to handle any other type of exception
        Write-Warning "Unable to run script for $name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace
    }
}
