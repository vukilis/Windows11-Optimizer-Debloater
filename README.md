# Windows11-Optimizer-Debloater
![version](https://img.shields.io/badge/version%20-2.3-lighgreen)
[![changelog](https://img.shields.io/badge/📋-release%20notes-00B2EE.svg)](https://github.com/vukilis/Windows11-Optimizer-Debloater/blob/dev/CHANGELOG.md)  
This Utility show basic system information, install programs, debloat and optimize Windows with tweaks, troubleshoot with config, and fix Windows updates.

## Usage:

Requires you to launch PowerShell or Windows Terminal As ADMINISTRATOR!

Launch Command:
```
iwr -useb maglit.me/win11app | iex
```
or 
```
irm maglit.me/win11app | iex
```
If you are having TLS 1.2 Issues or You cannot find or resolve `maglit.me/win11app` then run with the following command:
```
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/win11deb.ps1')
```
[MagLit](https://github.com/NayamAmarshe/MagLit) - Free and Open Source Privacy Respecting Encrypted Magnet/HTTP(s) Link Shortener with Password Protection.

## What Script Do?
- **Info**
  > Shows system information
- **Install**
  > Install applications from winget, choco and pip.
- **Debloat**
  > Removes unnecessary preinstalled apps.
- **Optimization**
  > Optimizes Windows and reduces running processes  
  > Has different presets
- **Services**
  > Sets services to disabled or manual  
  > Has three modes - recommended, gaming, normal  
  > Shows services status
- **Updates**
  > Fixes the default Windows update scheme  
  > Reset Windows Update to factory settings
- **Config**
  > Quick configurations for Windows Installs  
  > Has old legacy panels from Windows 7

## Credits
- Special thanks to [jepriCreations](https://www.deviantart.com/rosea92) for his amazing Windows 11 cursor concept.
- Here is the original [link](https://www.deviantart.com/jepricreations/art/Windows-11-Free-Tail-Cursor-Concept-962242647) to the free version.
- You can find a more complete version with HD resolution and some cool alternatives in the next [link](https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-HD-v2-890672103)
