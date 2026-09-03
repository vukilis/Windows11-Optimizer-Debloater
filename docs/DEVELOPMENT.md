# Development Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Source Files                             │
│  scripts/start.ps1 ──► Entry point, elevation, parameters       │
│  scripts/main.ps1 ──► WPF UI, event routing                     │
│  scripts/closure.ps1 ──► Finalization, window display           │
│  functions/... ──► Modular feature implementations              │
│  config/*.json ──► Data-driven configuration                    │
│  xaml/MainWindow.xaml ──► UI layout                             │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      compile.ps1                                │
│  1. Validate all JSON configs                                   │
│  2. Embed JSON as PowerShell variables                          │
│  3. Concatenate scripts in order                                │
│  4. Output: win11deb.ps1                                       │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    win11deb.ps1 (artifact)                      │
│  - Single-file, self-contained PowerShell script                │
│  - Can be run directly or distributed                           │
│  - Downloads XAML from GitHub if local file missing             │
└─────────────────────────────────────────────────────────────────┘
```

## Build Process

The project uses a **compile-time concatenation** model:

1. **Source files** are organized in `scripts/` and `functions/`
2. **`compile.ps1`** validates, embeds, and concatenates everything into `win11deb.ps1`
3. The **artifact** (`win11deb.ps1`) is a single self-contained script

### Build Steps

```powershell
# 1. Validate and compile
.\compile.ps1

# 2. Run smoke test
.\win11deb.ps1 -SmokeTest

# 3. Run with UI
.\win11deb.ps1
```

## Runtime Flow

1. `start.ps1` runs first:
   - Self-elevates to admin if needed
   - Starts transcript logging
   - Defines `$ScriptVersion`

2. `main.ps1` loads:
   - XAML from local file or GitHub fallback
   - WPF assemblies
   - Binds all `wpf_*` controls to event handlers
   - Defines `Invoke-Button`, `Invoke-ToggleButtons`, etc.

3. `closure.ps1` runs last:
   - Checks PowerShell version
   - Binds additional event handlers
   - Shows the main window

## Adding New Features

### New Tweak

1. Add entry to `config/tweaks.json`
2. If needed, add helper function to `functions/private/optimization/` or `functions/private/helper/`
3. Run `.\compile.ps1`

### New Config Button

1. Add entry to `config/configuration.json`
2. Add handler in `functions/public/config/Invoke-Configs.ps1`
3. Run `.\compile.ps1`

### New Install Application

1. Add entry to `config/applications.json`
2. Run `.\compile.ps1`

## Debugging

- **Logs**: `$ENV:TEMP\win11deb.log`
- **Smoke test**: `.\win11deb.ps1 -SmokeTest` validates configs without UI
- **Breakpoints**: You can debug `win11deb.ps1` directly in VS Code

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| Single compiled artifact | Easy distribution; users run one file |
| JSON-driven configs | Non-developers can edit tweaks without touching PS code |
| WPF with XAML | Native Windows UI, no external dependencies |
| Dictionary-based routing | Replaces massive switch statements; easier to extend |
