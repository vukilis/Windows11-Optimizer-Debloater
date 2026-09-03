function Invoke-LoadNativeMethods {
    <#
    .SYNOPSIS
        Loads native Windows method types once and caches them.

    .PARAMETER Type
        The name of the native method type to load. Valid values: RefreshSystem, SystemParamInfo.

    .EXAMPLE
        Invoke-LoadNativeMethods -Type RefreshSystem
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateSet('RefreshSystem', 'SystemParamInfo')]
        [string]$Type
    )

    switch ($Type) {
        'RefreshSystem' {
            if (-not [type]::GetType('RefreshSystem')) {
                Add-Type @"
using System;
using System.Runtime.InteropServices;
public class RefreshSystem {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@
            }
        }
        'SystemParamInfo' {
            if (-not [type]::GetType('SystemParamInfo')) {
                Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class SystemParamInfo {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@
            }
        }
    }
}


