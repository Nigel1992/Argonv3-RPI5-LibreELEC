# 🛠️ Argon ONE V3 Setup Script for LibreELEC on Raspberry Pi 5

[![Version](https://img.shields.io/badge/version-1.2.2-blue)](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC/releases)
[![Platform](https://img.shields.io/badge/platform-LibreELEC-green)](https://libreelec.tv/)
[![RPi](https://img.shields.io/badge/device-Raspberry%20Pi%205-red)](https://www.raspberrypi.com/)
[![PowerShell](https://img.shields.io/badge/powershell-%3E%3D5.1-blue)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

## 📝 Description

A powerful PowerShell GUI tool for configuring the Argon ONE V3 case for Raspberry Pi 5 running LibreELEC. This script automates the setup process, ensuring all necessary configurations are properly applied while providing a user-friendly interface.

## 🚀 Quick Start

### Option 1: Direct Installation (Recommended)
```powershell
# Allow remote signed scripts (recommended, only needed once)
Set-ExecutionPolicy RemoteSigned -Force

# Run the script
irm https://raw.githubusercontent.com/Nigel1992/Argonv3-RPI5-LibreELEC/main/argonv3.ps1 | iex
```

### Option 2: Manual Installation
1. Download the script from the [releases page](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC/releases)
2. Right-click the script and select "Properties"
3. Check the "Unblock" box and click OK
4. Run with PowerShell

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🖥️ GUI Interface | Modern, intuitive graphical user interface |
| 🌡️ Fan Control | Advanced temperature-based fan control |
| ⚡ Power Management | Customizable power button actions |
| 💾 Config Backup | Creates backups of your settings |
| 📊 Monitoring | Real-time temperature and fan monitoring |
| 📝 Logging | Comprehensive logging system |
| 🔒 Secure | Safe SSH connection handling |
| 📋 Reports | Configuration status reports |

## 🔧 Configuration Options

### Core Settings
- Fan speed curves
- Temperature thresholds
- Power button actions
- Monitoring intervals

### Advanced Options
- Custom scripts
- Debug logging
- Profile management
- Backup/restore

## 📋 System Requirements

- Windows OS with PowerShell 5.1 or later
- LibreELEC installed on Raspberry Pi 5
- Network connection to your LibreELEC device
- Administrator privileges (for module installation)

## 📁 File Locations

```plaintext
%USERPROFILE%\Documents\ArgonSetup\
├── argon_settings.xml       # User settings
├── connection_settings.xml  # Connection details
└── logs\                   # Log directory
    └── argon_setup_*.log   # Session logs
```

## 🔍 Usage Guide

1. **Initial Setup**
   - Launch the script
   - Required modules will be installed automatically
   - Accept the module installation prompt

2. **Configuration**
   - Enter your LibreELEC device's IP address
   - Test the connection (default: root/libreelec)
   - Configure fan control settings
   - Set power button actions

3. **Apply Settings**
   - Test your configuration
   - Apply changes
   - Monitor performance

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues, suggestions, or contributions:
- Open an [issue](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC/issues)
- Submit a [pull request](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC/pulls)
- Check the [discussions](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC/discussions)

---

<div align="center">
Made with ❤️ by Nigel Hagen
</div>
