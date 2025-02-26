# 🛠️ Argon ONE V3 Setup Script for LibreELEC on Raspberry Pi 5

![Version](https://img.shields.io/badge/version-1.2.0-blue)
![Platform](https://img.shields.io/badge/platform-LibreELEC-green)
![RPi](https://img.shields.io/badge/device-Raspberry%20Pi%205-red)

## 📝 Description

This PowerShell script provides an easy-to-use GUI for configuring the Argon ONE V3 case for Raspberry Pi 5 running LibreELEC. It automates the setup process and ensures all necessary configurations are properly applied.

## ✨ Features

- 🖥️ User-friendly graphical interface
- 🔄 Automatic configuration of required settings
- 💾 Backup creation before modifications
- 📊 Real-time progress monitoring
- 📝 Detailed logging system
- 🔒 Secure SSH connection handling
- ⚡ Power button functionality setup
- 🌡️ Fan control configuration

## 🚀 Quick Start

1. Download the script
2. Run it with PowerShell
3. Enter your LibreELEC device's:
   - IP Address
   - Username (default: root)
   - Password

## 🔧 What It Configures

- GPIO settings for IR receiver
- I2C interface
- UART configuration
- USB power settings
- Fan control parameters
- Power button functionality

## 📋 Requirements

- Windows with PowerShell 5.1 or later
- LibreELEC installed on Raspberry Pi 5
- Network connection to your Pi
- Argon ONE V3 case

## 💡 Usage

1. Launch the script
2. Fill in connection details
3. Click "Test Connection"
4. Click "Apply Configuration"
5. Wait for completion
6. Reboot your device

## 🔍 Logging

The script maintains detailed logs of all operations, including:
- Connection attempts
- Configuration changes
- Backup creation
- Error messages
- Success confirmations

## 🛟 Backup System

Before making any changes, the script can:
- Create backups of existing configurations
- Store them in `/storage/ArgonScriptBackup`
- Add timestamps for easy identification
- Verify backup success

## ⚠️ Important Notes

- Always test connection before applying changes
- Backup option is recommended
- Reboot required after configuration
- Check logs for detailed information

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Argon40 for the amazing case
- LibreELEC team
- Raspberry Pi community

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Check existing issues for solutions
- Include log files when reporting problems

---
Made with ❤️ for the Raspberry Pi community
