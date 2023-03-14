# Windows11-Optimizer-Debloater
This Utility show basic system information, debloat and optimize Windows with tweaks, troubleshoot with config, and fix Windows updates.

Requires you to launch PowerShell or Windows Terminal As ADMINISTRATOR!

Launch Command:

```
irm tinyurl.com/win11deb | iex
```
If you are having TLS 1.2 Issues or You cannot find or resolve `tinyurl.com/win11deb` then run with the following command:
```
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/main.ps1')
```
## What Script Do?
- **Info**
  > Shows system information
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