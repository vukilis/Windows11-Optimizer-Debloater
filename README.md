# Windows11-Optimizer-Debloater
![version](https://img.shields.io/badge/version%20-2.9-lighgreen)
[![changelog](https://img.shields.io/badge/📋-release%20notes-00B2EE.svg)](https://github.com/vukilis/Windows11-Optimizer-Debloater/blob/dev/CHANGELOG.md)  
This Utility show basic system information, install programs, debloat and optimize Windows with tweaks, troubleshoot with config, and fix Windows updates.

## Usage:

Requires you to launch PowerShell or Windows Terminal As ADMINISTRATOR!

Launch Command:
```
iwr -useb vukilis.com/win11deb | iex
```
or 
```
iwr -useb dub.sh/win11deb | iex
irm dub.sh/win11deb | iex
```
If you are having TLS 1.2 Issues or You cannot find or resolve `dub.sh/win11deb` then run with the following command:
```
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/win11deb.ps1')
```
[Dub.co](https://github.com/dubinc/dub) - An open-source link management tool for modern marketing teams to create, share, and track short links.

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
  > Pauses Windows updates to 5 week
- **Config**
  > Quick configurations for Windows Installs  
  > Has old legacy panels from Windows 7  
  > Makes shortcuts and backups  
  > Fixes and sets configs for applications  
  > Activate Windows with MAS script

## Credits
- Special thanks to [jepriCreations](https://www.deviantart.com/rosea92) for his amazing Windows 11 cursor concept.
  > Here is the official [link](https://www.deviantart.com/jepricreations/art/Windows-11-Free-Tail-Cursor-Concept-962242647) of the free version.  
  > You can find a more complete version with HD resolution and some cool alternatives in the next [link](https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-HD-v2-890672103)

- Special thanks to [massgravel](https://github.com/massgravel) for his amazing Windows and Office activator.
  > Here is the official [link](https://github.com/massgravel/Microsoft-Activation-Scripts).
