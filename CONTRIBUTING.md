# Contributing to Windows11 Optimizer & Debloater

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Development Setup

### Prerequisites

- PowerShell 7.0 or higher
- Windows 11 (for testing WPF UI)
- Git

### Clone and Build

```powershell
git clone https://github.com/vukilis/Windows11-Optimizer-Debloater.git
cd Windows11-Optimizer-Debloater
.\compile.ps1
```

### Project Structure

```
.
├── compile.ps1              # Build script that compiles source into win11deb.ps1
├── scripts/
│   ├── start.ps1            # Entry point: elevation, logging, parameters
│   ├── main.ps1             # WPF UI initialization and event routing
│   └── closure.ps1          # Finalization: version check, window display
├── functions/
│   ├── private/             # Internal helper functions
│   │   ├── helper/          # Registry, services, firewall, UI helpers
│   │   ├── optimization/    # Optimization tweaks
│   │   ├── debloat/         # App removal logic
│   │   ├── installs/        # Package management
│   │   └── config/          # Configuration helpers
│   └── public/              # Public-facing functions
│       ├── info/            # System information
│       ├── installs/        # Install/uninstall/upgrade buttons
│       ├── debloat/         # Debloat UI handlers
│       ├── optimization/    # Optimization UI handlers
│       ├── services/        # Service presets
│       ├── updates/         # Windows Update handlers
│       └── config/          # Config panel handlers
├── config/
│   ├── tweaks.json          # Tweak definitions (registry, scripts, services)
│   ├── preset.json          # Preset configurations
│   ├── feature.json         # Windows feature toggles
│   ├── configuration.json   # Config panel buttons
│   ├── applications.json    # Winget application list
│   └── msAppxDebloat.json   # AppX debloat list
├── xaml/
│   └── MainWindow.xaml      # WPF UI definition
└── tests/
    └── Core.Tests.ps1       # Pester tests
```

## Adding a New Tweak

1. Open `config/tweaks.json`
2. Add a new entry with the following structure:

```json
"DblMyTweak": {
    "Type": "CheckBox",
    "Content": "My New Tweak",
    "Description": "Description of what this tweak does.",
    "DisableMessage": "Disabling My New Tweak...",
    "registry": [
        {
            "Path": "HKLM:\\SOFTWARE\\Example\\Path",
            "Name": "ValueName",
            "Value": 0,
            "OriginalValue": 1,
            "Type": "DWord"
        }
    ],
    "InvokeScript": [
        "Write-Host 'Applying tweak...'"
    ],
    "UndoScript": [
        "Write-Host 'Reverting tweak...'"
    ]
}
```

3. Ensure the key uses **camelCase** (`registry`, not `Registry`)
4. Run `.\compile.ps1` to regenerate `win11deb.ps1`
5. Test the tweak in the UI

## Coding Standards

- **PowerShell 7.0+**: Use modern PowerShell features (pipeline chaining, ternary, etc.)
- **StrictMode**: All source files are compiled with `Set-StrictMode -Version Latest`
- **Error Handling**: Never use empty `catch {}` blocks. Always log warnings.
- **No Invoke-Expression**: Use the call operator `&` instead
- **Registry Values**: Use `<RemoveEntry>` to delete a registry value
- **Documentation**: Include `.SYNOPSIS`, `.PARAMETER`, `.EXAMPLE` in all public functions

## Testing

```powershell
# Run Pester tests
Invoke-Pester -Script .\tests\Core.Tests.ps1

# Run smoke test (no UI)
.\win11deb.ps1 -SmokeTest
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-new-tweak`)
3. Make your changes
4. Run `.\compile.ps1` and test the output
5. Ensure all Pester tests pass
6. Submit a pull request to the `dev` branch

## Code of Conduct

- Be respectful and constructive
- Focus on the issue, not the person
- Accept feedback gracefully
