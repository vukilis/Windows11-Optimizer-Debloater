# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Known Issues]

- **display performance tweak** - shows incorrect settings, but visually it's correct, after restart computer it shows how need to be.
- When launch script, **Info** tab button is not visually selected.

## [2.0] - 2023-12-27

### Changed

- Restructured project to help easier develop and debug code.
- Each function is separated to mini **.ps1** file.
- Code improved for **Fix Windows Update** function.

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