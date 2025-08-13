# Load JSON from file
$jsonPath = ".\config\tweaks.json"
$sync = @{
    configs = @{
        tweaks = (Get-Content -Path $jsonPath -Raw | ConvertFrom-Json)
    }
}

function Get-ToggleStatus {
    Param([string]$ToggleSwitch)

    $ToggleSwitchReg = $sync.configs.tweaks.$ToggleSwitch.registry

    try {
        if (($ToggleSwitchReg.path -imatch "hku") -and !(Get-PSDrive -Name HKU -ErrorAction SilentlyContinue)) {
            $null = (New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS)
        }
    } catch {
        Write-Error "An error occurred regarding the HKU Drive: $_"
        return $false
    }

    if ($ToggleSwitchReg) {
        $count = 0

        foreach ($regentry in $ToggleSwitchReg) {
            try {
                if (!(Test-Path $regentry.Path)) {
                    New-Item -Path $regentry.Path -Force | Out-Null
                }

                $regstate = (Get-ItemProperty -Path $regentry.Path -ErrorAction Stop).$($regentry.Name)

                if ($regstate -eq $regentry.Value) {
                    $count += 1
                }
                elseif (-not $regstate) {
                    switch ($regentry.DefaultState) {
                        "true"  { $count += 1 }
                        "false" { }
                        default { }
                    }
                }
            } catch {
                Write-Error "An unexpected error occurred: $_"
            }
        }

        return ($count -eq $ToggleSwitchReg.Count)
    } else {
        return $false
    }
}

# Get all WPF ToggleButtons
$toggleButtons = Get-Variable | Where-Object {
    $_.Name -like "wpf_*" -and
    $_.Value -ne $null -and
    $_.Value.GetType().Name -eq "ToggleButton"
} | ForEach-Object { $_.Value }

# Set each ToggleButton's state at startup
foreach ($btn in $toggleButtons) {
    $toggleName = $btn.Name -replace '^wpf_', ''
    $isChecked = Get-ToggleStatus -ToggleSwitch $toggleName
    $btn.IsChecked = $isChecked
}
