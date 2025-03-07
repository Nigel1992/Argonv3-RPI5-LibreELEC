# 🛠️ Argon ONE V3 Setup Script for LibreELEC on Raspberry Pi 5

[![Version](https://img.shields.io/badge/version-1.2.2-blue)](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC/releases)
[![Platform](https://img.shields.io/badge/platform-LibreELEC-green)](https://libreelec.tv/)
[![RPi](https://img.shields.io/badge/device-Raspberry%20Pi%205-red)](https://www.raspberrypi.com/)
[![PowerShell](https://img.shields.io/badge/powershell-%3E%3D5.1-blue)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

## 📝 Description

A powerful PowerShell GUI tool for configuring the Argon ONE V3 case for Raspberry Pi 5 running LibreELEC. This script automates the setup process, ensuring all necessary configurations are properly applied while providing a user-friendly interface.

![Argon ONE V3 Setup Interface](https://github.com/user-attachments/assets/62c1119e-e62d-4256-9d45-d1853e8d2d63)

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
| 🔄 Auto Config | Automatic configuration of required settings |
| 💾 Backup System | Creates backups before any modifications |
| 📊 Progress Tracking | Real-time progress monitoring |
| 📝 Logging | Comprehensive logging system |
| 🌓 Themes | Dark/Light theme support |
| 🔒 Secure SSH | Safe and secure SSH connection handling |
| 📋 HTML Reports | Detailed configuration reports |

## 🔧 Configuration Options

### Core Settings
- GPIO settings for IR receiver
- I2C interface configuration
- UART settings
- USB power management
- Fan control parameters
- Power button functionality

### Advanced Options
- NVMe support (Argon V3 with NVMe)
- PCIe generation selection (Gen 1/2/3)
- HiFiBerry DAC support
- Automatic backup creation
- Custom configuration testing

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
   - Select your Argon V3 version
   - Choose additional options (NVMe, DAC)

3. **Apply Settings**
   - Click "Test Current Settings" to verify
   - Use "Apply Configuration" to save changes
   - Review logs with "Show Log" button

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
