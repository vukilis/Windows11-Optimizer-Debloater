# Windows11-Optimizer-Debloater
Windows Utility - Tweaks, Fixes, and Updates

Requires you to launch PowerShell or Windows Terminal As ADMINISTRATOR!

Launch Command:

```
irm tinyurl.com/win11deb | iex
```
If you are having TLS 1.2 Issues or You cannot find or resolve `tinyurl.com/win11deb` then run with the following command:
```
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/vukilis/Windows11-Optimizer-Debloater/main/main.ps1')
```