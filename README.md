# 🛠️ Argon ONE V3 Setup Script for LibreELEC on Raspberry Pi 5

![Version](https://img.shields.io/badge/version-1.2.1-blue)
![Platform](https://img.shields.io/badge/platform-LibreELEC-green)
![RPi](https://img.shields.io/badge/device-Raspberry%20Pi%205-red)

## 📝 Description

This PowerShell script provides an easy-to-use GUI for configuring the Argon ONE V3 case for Raspberry Pi 5 running LibreELEC. It automates the setup process and ensures all necessary configurations are properly applied.

![{77D0D9BC-2A71-40FB-B5BA-894F4F25D521}](https://github.com/user-attachments/assets/d48aabef-6a30-4fe0-af09-c5bc42199b40)


## 🚀 Quick Start

Run directly from PowerShell (Administrator):
```powershell
# First, allow remote script execution (only needed once)
Set-ExecutionPolicy Unrestricted -Force

# Then run the script
irm https://raw.githubusercontent.com/nigelhagen/argon-libreelec-setup/main/argonv3.ps1 | iex
```

Or for a more secure approach, you can use:
```powershell
# Allow remote signed scripts (recommended, only needed once)
Set-ExecutionPolicy RemoteSigned -Force

# Then run the script
irm https://raw.githubusercontent.com/nigelhagen/argon-libreelec-setup/main/argonv3.ps1 | iex
```

Alternatively, download and run manually (you'll need to do this every time the script gets an update, so not recommended):
1. Download the script
2. Right-click the script and select "Properties"
3. Check the "Unblock" box and click OK
4. Run it with PowerShell

## ✨ Features

- 🖥️ User-friendly graphical interface
- 🔄 Automatic configuration of required settings
- 💾 Backup creation before modifications
- 📊 Real-time progress monitoring
- 📝 Detailed logging system
- 🔒 Secure SSH connection handling
- ⚡ Power button functionality setup
- 🌡️ Fan control configuration

## 🔧 What It Configures

- GPIO settings for IR receiver
- I2C interface
- UART configuration
- USB power settings
- Fan control parameters
- Power button functionality
- NVMe support (for Argon V3 with NVMe)
- DAC support (optional)

## 📋 Requirements

- Windows with PowerShell 5.1 or later
- LibreELEC installed on Raspberry Pi 5
- Network connection to your LibreELEC device

## Features
- Easy configuration of Argon V3 case settings
- Support for both normal and NVMe versions
- PCIe generation selection (Gen 1/2/3)
- HiFiBerry DAC support
- Automatic backup creation
- Dark/Light theme toggle
- Session-based logging
- Current settings test functionality
- HTML-based configuration reports

## Installation
1. Download the latest release
2. Run the script using PowerShell
3. Required modules will be installed automatically

## Usage
1. Enter your LibreELEC device's IP address
2. Test the connection (default credentials: root/libreelec)
3. Select your Argon V3 version and options
4. Click "Test Current Settings" to view current configuration
5. Click "Apply Configuration" to save changes
6. View logs anytime using the "Show Log" button

## File Locations
- Settings: `%USERPROFILE%\Documents\ArgonSetup\argon_settings.xml`
- Logs: `%USERPROFILE%\Documents\ArgonSetup\logs\argon_setup_[timestamp].log`
- HTML Reports: `%USERPROFILE%\Documents\ArgonSetup\current_settings.html`

## Support
For issues or suggestions, please visit the GitHub repository.

## License
MIT License - See LICENSE file for details
