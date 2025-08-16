# Load JSON from file
$configUrl = "https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/config"
$files   = @("tweak.json")  # add all your JSON files here

$sync = @{ configs = @{} }

foreach ($file in $files) {
    $url = "$configUrl/$file"
    try {
        $json = Invoke-RestMethod -Uri $url -UseBasicParsing
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $sync.configs[$baseName] = $json
        Write-Host "Loaded remote config: $file" -ForegroundColor Cyan
    }
    catch {
        Write-Warning "Failed to load JSON from $url : $_"
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

# Set each ToggleButton state at startup
foreach ($btn in $toggleButtons) {
    $toggleName = $btn.Name -replace '^wpf_', ''
    $isChecked = Get-ToggleStatus -ToggleSwitch $toggleName
    $btn.IsChecked = $isChecked
}
