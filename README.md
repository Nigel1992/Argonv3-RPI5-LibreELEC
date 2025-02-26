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
- Network connection to your Pi
- Argon ONE V3 case
- Internet connection (for first run to install required module)

## 💡 Usage

1. Launch the script using either method above
2. Fill in connection details:
   - IP Address (find in Kodi under System → System info → Network)
   - Username (default: root)
   - Password (default: libreelec)
3. Click "Test Connection"
4. Select your Argon V3 version:
   - Normal
   - With NVMe
5. Configure additional options:
   - PCIe Generation (for NVMe version)
   - DAC support (if using Argon DAC)
6. Click "Apply Configuration"
7. Choose whether to create backups
8. Wait for completion
9. Reboot your device when prompted

## 🔍 Logging

The script maintains detailed logs of all operations, including:
- Connection attempts
- Configuration changes
- Backup creation
- Error messages
- Success confirmations

Click "Show Log" in the interface to view detailed operation logs.

## 🛟 Backup System

Before making any changes, the script can:
- Create backups of existing configurations
- Store them in `/storage/ArgonScriptBackup`
- Add timestamps for easy identification
- Verify backup success
- Maintain multiple backup versions

## 💾 Settings Storage

The script stores settings in your Documents folder:
- Connection settings for quick reconnection
- Configuration preferences
- All settings are stored locally

## ⚠️ Important Notes

- Always test connection before applying changes
- Backup option is recommended
- Reboot required after configuration
- Check logs for detailed information
- Settings are saved in Documents/ArgonSetup
- First run requires internet to install SSH module

## 🔒 Security

- Passwords are handled securely
- SSH connections use secure protocols
- No data is transmitted online
- All operations are logged for verification
  
## 🔷 To-Do
- Fix log scrolling

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your experience
- Help others in discussions

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Argon40 for the amazing case
- LibreELEC team
- Raspberry Pi community
- PowerShell community
- All contributors and testers

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Check existing issues for solutions
- Include log files when reporting problems
- Provide your LibreELEC version
- Specify your Argon case version

## 🔄 Updates

You can always get the latest version using the USAGE commands above.

## 🛠️ Troubleshooting

Common issues and solutions:
1. SSH Connection Failed:
   - Verify IP address in Kodi
   - Ensure SSH is enabled in LibreELEC
   - Check network connectivity
   - Verify credentials

2. Module Installation Issues:
   - Run PowerShell as Administrator
   - Ensure internet connectivity
   - Check Windows PowerShell version

3. Configuration Issues:
   - Check logs for detailed error messages
   - Verify LibreELEC version compatibility
   - Ensure proper permissions
   - Check available space in /storage

---
Made with ❤️ for the Raspberry Pi community
