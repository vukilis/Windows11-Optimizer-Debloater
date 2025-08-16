# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Known Issues]

- **display performance tweak** - shows incorrect settings, but visually it's correct, after restart computer it shows how need to be.

## [3.2] - 2025-08-16

### Added

- New config JSON files for managing tweaks and presets.
- New helper function to invoke a provided script block - **Invoke-SCripts**
- New optimization function **Set-ScheduledTask** to disable the specified scheduled task.
- New function **Get-ToggleStatus** to check whether toggle tweaks should be enabled or disabled.
- New function **Set-DynamicToolTip** to dynamically assign descriptions to tweak buttons.
- New function **Invoke-ExplorerUpdate** to restart Windows Explorer.
- New Tweaks: **Snap Window**,  **Snap Assist Suggestion**, **Snap Assist Bar**, **Widget Button in Taskbar**, **Prefer IPv4 over IPv6**, **Disable Microsoft Copilot**

### Changed

- Enhanced **Set-RegistryValue** function to better handle registry operations based on provided inputs.
- Optimization tweaks are now stored as JSON objects in external files.
- Enhanced all optimization tweaks and improved compatibility with the latest Windows build.
- Changed logic for handling **ToggleButton** components and improve consistency and maintainability.
- Modified XAML layout: replaced preset **ToggleButtons** (acting as checkboxes) with updated ToggleButton components for improved UI. control.
- Introduced new logic for the **Invoke-OptimizationButton**, **Invoke-ToggleFastPreset** and **Invoke-ToggleMegaPreset** function to handle checkbox tweaks from the JSON file.
- Replaced **Remove Microsoft Edge** option with **Debloat Microsoft Edge** for more control over Edge customization.
- Moved tweaks **Disable IPv6**, **Disable Teredo**, **Classic Right-Click Menu**, **Time UTC (Dual Boot)**, **Remove Cortana (deprecated)**, **Remove OneDrive** to the new **Advanced Tweaks** section.
- Removed all unnecessary legacy functions and files.

## [3.1] - 2025-08-03

### Added

- **Buy Me a Coffee** and **Ko-fi** donation buttons to the About page for user support.
- Toggle tweak to Enable/Disable Password Reveal Button, hide your password in a password entry text box in Windows 11  - **Password Reveal Button** 
- **Disable ConsumerFeatures** - Tweak that preventing unwanted apps, games, or links from auto-installing. Also, disabling features like Phone Link
- Disabling Powershell 7 Telemetry - **Disable PowerShell 7 Telemetry**

### Changed

- **Improved Window Management**: Added checks for IsVisible and IsLoaded to prevent opening the window multiple times.

## [3.0] - 2025-07-22

### Added

- Toggle tweak to Left/Center taskbar items - **Center Taskbar Items** 
- Toggle tweak to Enable/Disable more detailed BSoD - **Enable Detailed BSoD** 
- New essential tweak: **Disable Search Indexer** — disables Windows Search indexing service to improve system performance 
- **Get-RegistryValue** as a handler function to retrieve registry keys more efficiently and safely, with fallback handling for missing or inaccessible values.

### Changed

- Simplified `Get-CheckerTweaks` by replacing direct registry access with `Get-RegistryValue` wrapper function.
- Improved code maintainability and UI state sync.


## [2.9] - 2024-11-03

### Added

- Toggle tweak to disable/enable End Task in Taskbar by Right Click - **Enable End Task**  

## [2.8] - 2024-05-25

### Added

- **Create Registry Backup** button to backup your registry.
- **MessageBox** alert for registry backup.

### Changed

- Improved code for shortcut creation, now has better console output.

## [2.7] - 2024-05-06

### Added

- Toggle tweak to disable/enable Windows Copilot - **Copilot**.
- Toggle tweak to disable/enable Sticky Keys - **Sticky Keys**.

## [2.6] - 2024-01-27

### Added

- New apps in the install menu.
- Show red alert track if script is not run with administrator rights.

### Changed

- Descriptions for debloat functions.

### Fix

- **Remove Widgets** from stayed checked to unchecked after tweaking.

## [2.5] - 2024-01-19

### Added

- New tweak **Remove Widgets**.
- New app in the install menu. 
- Activator for Windows and Office - **Microsoft Activation Scripts (MAS)**.
- Custom code for maximizing the window when it is dragged to the edge of the screen.
 
### Changed

- Adjusted presets: 
**Lite Preset**
**Dev Preset**
**Gaming Preset**
**Fast Preset**
**Mega Preset**
- Recoded and redesigned **DEBLOAT TAB**, allowed user to choose what MSAppx want to uninstall and added **XBOX Preset**.

## [2.4] - 2024-01-14

### Added

- Button to show **About** window.
- Handler function for **ToggleButtons**.
- **Date release** next to version.

### Changed

- Buttons and UI color.
- Improved **double-click** to maximize window.

## [2.3] - 2024-01-11

### Added

- Displays the current version of the application.

### Changed

- From default to custom window controls: **minimize**, **maximize** and **close**.
- Improved shortcut creation, newly created shortcut has enabled by default **Run As Administrator** in Advanced Properties. This allowed to run script direct from first powershell window and show custom icon on taskbar.

### Fix

- When application is launched, it not showing active **tab**.

## [2.2] - 2024-01-09

### Added

- Bring back Thorium browser after the drama with Furries and Alex's Response. His Response: [link](https://alex313031.blogspot.com/2024/01/the-good-bad-and-ugly.html).
- New tweaks:  
**Disable Core Isolation**,  
**Disable Teredo**,  
**Disable Auto Adjust Volume**,  
**Disable Windows Sound**,  
**Classic alt+tab**,    
**Empty Recycle Bin**,  
**Verbose Logon Messages**,  
**Disable Snap Layout**,  
custom modern **Cursor** dark/light. 
- Added checkboxes for **System Restore Point** and **Restart Computer**.

### Changed

- **UI** Improved
- Now can be enabled/disabled the creation of system restore point when tweaking. Enabled by Default!
- Now can be enabled/disabled restart computer after tweaking. Disabled by default!
- Improved code for **services** tab.

## [2.1] - 2024-01-05

### Added

- New apps in the install menu.
- **Pause Windows Update** button up to 35 days or 5 weeks in the **updates** menu. 
- **Shortcut** for easier and faster access to script.
- Buttons to fix network and sound in the **config** menu.
- Buttons to configure **winget** settings and **Android Debug Bridge (adb)** environment.

### Changed

- **UI** Redesigned.
- Improved code for **Info** tab.

## [2.0] - 2023-12-30

### Changed

- Restructured project to help easier develop and debug code.
- Each function is separated to mini **.ps1** file.
- Code improved for **Fix Windows Update** function.
- Shortener provider from tinyurl to **maglit.me** 

## [1.9] - 2023-12-26

### Added

- Buttons to install, upgrade and uninstall **chocolatey**.
- Button to fix **winget**.
- Button to fix **Microsoft Store**.
- MessageBox when debloat, tweaking updates and services are finished.
- New apps in the install menu.

### Changed

- No more installing **Chocolatey** automatically. 
- Improved Code Quality

### Fix

- Code for **Debloat**, now it's working with **pwsh**.

## [1.8] - 2023-12-17

### Added

- **Search bar** to filter applications. It's hided if not selected **Install** tab.
- **Reset** button to reset search filter.

### Changed

- **UI** and improved. 
- Tab buttons to **radioButtons** and now have color effects. 
- The colors for the general **buttons**.
- Appearance for checkboxes and comboboxes.

### Fix

- Uninstall and upgrade with **choco** package manager.
- Color output for uninstall and upgrade packages. 

## [1.7] - 2023-12-14

### Added

- Possibility to install applications with **pip**.
- Legendary, heroic, spotify, and Figma to **Install** tab.

### Changed

- Improved Code Quality

## [1.6] - 2023-12-12

### Added

- **Install** tab to install winget applications.
- Presets for faster installation.
- **region** settings to **config** tab.
- Possibility to scrolling.

### Changed

- Background and text color in **optimization** tab are adjusted to new **Install** tab.

## [1.5] - 2023-12-05

### Added

- Create restore point before run optimization tweaking.

### Changed

- Improved Code Quality.
- removed garbage code.

### Fix

- No more output error for some services. 

## [1.4] - 2023-12-03

### Added

- Toggle tweak to show/hide hidden files  - **Show Hidden Files**.
- Toggle tweak to show/hide search box - **Hide Search Box**.

### Changed

- Tweak **Disable Telemetry** now disable widgets.

## [1.3] - 2023-12-02

### Added

- MessageBox when tweaks are finished.
- Toggle tweak to disable/enable bing in start menu  - **Bing Search In Start Menu**.
- Toggle tweak to disable/enable IPv6 - **IPv6**.
- New optimization tweak to remove Microsoft Edge - **Remove Microsoft Edge**.
- New optimization tweak to remove OneDrive - **Remove OneDrive**.

### Changed

- Optimization tweak **NumLock On Startup** is now toggle tweak.
- Optimization tweak **Show File Extensions** is now toggle tweak.
- Optimization tweak **Mouse Acceleration** is now toggle tweak.
- On hover cursor from **Arrow** to **Hand** on all buttons, checkboxes and select elements. 
- Some visual and functionality fixes.

## [1.2] - 2023-11-20

### Added

- Removes new unnecessary preinstalled app - **Dev Home**.

## [1.1] - 2023-11-10

### Added

- New optimization tweak - **Personalisation Settings**.
- README now contains version and release notes badges.
