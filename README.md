# Windows11-Optimizer-Debloater
![GitHub Release](https://img.shields.io/github/v/release/vukilis/Windows11-Optimizer-Debloater?style=flat&logo=futurelearn&logoColor=%2332a850&label=LATEST%20RELEASE&color=%2332a850)
[![changelog](https://img.shields.io/badge/📋-RELEASE%20NOTES-00B2EE.svg)](https://github.com/vukilis/Windows11-Optimizer-Debloater/blob/dev/CHANGELOG.md) 
[![Total number of downloads](https://img.shields.io/github/downloads/vukilis/Windows11-Optimizer-Debloater/total?style=flat&label=TOTAL%20DOWNLOADS&labelColor=444&logo=hack-the-box&logoColor=white&cacheSeconds=600)](https://github.com/ungive/discord-music-presence/releases)
[![Number of downloads of the latest version](https://img.shields.io/github/downloads/vukilis/Windows11-Optimizer-Debloater/latest/total?style=flat&label=Downloads%20%40latest&labelColor=444&logo=hack-the-box&logoColor=white&cacheSeconds=600)](https://github.com/ungive/discord-music-presence/releases/latest)
[![Number of GitHub stars](https://img.shields.io/github/stars/vukilis/Windows11-Optimizer-Debloater?style=flat&label=STARS&logo=github&labelColor=444&color=DAAA3F&cacheSeconds=3600)](https://star-history.com/#ungive/discord-music-presence&Date)
[![Number of GitHub stars](https://img.shields.io/github/stars/vukilis/Windows11-Optimizer-Debloater?style=flat&label=STARS&logo=github&labelColor=444&color=DAAA3F&cacheSeconds=3600)](https://star-history.com/#ungive/discord-music-presence&Date) [![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?style=flat&logo=windows&logoColor=white)](https://www.microsoft.com/windows/windows-11)
[![Buy me a beer](https://img.shields.io/badge/BUY%20ME%20A%20BEER-black?style=flat&logo=buymeacoffee&logoColor=black&color=FFDD00)](https://buymeacoffee.com/vukilis)
[![ko-fi](https://shields.io/badge/KO--FI-BEER-ff5f5f?logo=ko-fi&style=for-the-badgeKo-fi)](https://ko-fi.com/vukilis)

This Utility show basic system information, install programs, debloat and optimize Windows with tweaks, troubleshoot with config, and fix Windows updates.


![Screenshot of the application in the tray menu and the Discord status](https://vukilis.com/_astro/optimization.C4VRkIbL_Z2dEuaa.webp)

## Usage:

Requires you to launch PowerShell or Windows Terminal As ADMINISTRATOR!

Stable Branch (recommended):
```
iwr -useb vukilis.com/win11deb | iex
```

Development Branch:
```
iwr -useb vukilis.com/win11dev | iex
```

---

## What Script Do?

| Feature | Description |
|---------|-------------|
| ℹ️ **Info** | Shows system information |
| 📦 **Install** | Install applications from winget and choco |
| 🧹 **Debloat** | Removes unnecessary preinstalled apps |
| ⚡ **Optimization** | Optimizes Windows and reduces running processes<br>Has different presets |
| 🔄 **Updates** | Fixes the default Windows update scheme<br>Reset Windows Update to factory settings<br>Pauses Windows updates to 5 weeks |
| ⚙️ **Config** | Quick configurations for Windows Installs<br>Has old legacy panels from Windows 7<br>Makes shortcuts and backups<br>Fixes and sets configs for applications<br>Activate Windows with MAS script |

--- 

## Architecture

This project uses a **compile-time concatenation** architecture. Source files are organized by function and compiled into a single artifact.

```mermaid
graph LR
    A[scripts/start.ps1] --> C[compile.ps1]
    B[scripts/main.ps1] --> C
    D[scripts/closure.ps1] --> C
    E[functions/...] --> C
    F[config/*.json] --> C
    G[xaml/MainWindow.xaml] --> C
    C --> H[win11deb.ps1]
    H --> I[User runs script]
    I --> J[WPF UI]
```

### Key Design Decisions

| Decision | Description |
|----------|-------------|
| 📦 **Single Artifact** | All code is compiled into `win11deb.ps1` for easy distribution |
| 📋 **JSON-Driven** | Tweaks and configurations are defined in JSON, not hardcoded |
| 🖼️ **Local XAML** | UI layout is loaded from `xaml/MainWindow.xaml` with GitHub fallback |
| 🔗 **Dictionary Routing** | Button actions are mapped via hashtables instead of switch statements |

---

## Development

| Resource | Description |
|----------|-------------|
| 📝 [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines and workflow |
| 🛠️ [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) | Development setup and guidelines |

---

## Blog Post

| Resource | Description |
|----------|-------------|
| 📄 **[Windows 11 Optimizer & Debloater](https://vukilis.com/blog/2024/windows-11-optimizer-debloater/)** | In-depth article about the project |

---

## Credits

| Credit | Description |
|--------|-------------|
| 🖱️ **[jepriCreations](https://www.deviantart.com/rosea92)** | Windows 11 cursor concept<br>[Free version](https://www.deviantart.com/jepricreations/art/Windows-11-Free-Tail-Cursor-Concept-962242647) • [HD version](https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-HD-v2-890672103) |
| ⚡ **[massgravel](https://github.com/massgravel)** | Windows and Office activator<br>[Microsoft Activation Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts) |
