# 🛠️ Argon ONE V3 Setup Script for LibreELEC on Raspberry Pi 5

[![Version](https://img.shields.io/badge/version-1.3.0-blue)](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC)
[![Platform](https://img.shields.io/badge/platform-LibreELEC-green)](https://libreelec.tv/)
[![RPi](https://img.shields.io/badge/device-Raspberry%20Pi%205-red)](https://www.raspberrypi.com/)
[![PowerShell](https://img.shields.io/badge/powershell-%3E%3D5.1-blue)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

<details>
  
  <summary>Click to reveal image of GUI</summary>
![image]([https://github.com/user-attachments/assets/cd12fd4d-a54b-423c-982c-2fa4f268fbc7](https://private-user-images.githubusercontent.com/5491930/457607996-cd12fd4d-a54b-423c-982c-2fa4f268fbc7.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTA1NDE3NDQsIm5iZiI6MTc1MDU0MTQ0NCwicGF0aCI6Ii81NDkxOTMwLzQ1NzYwNzk5Ni1jZDEyZmQ0ZC1hNTRiLTQyM2MtOTgyYy0yZmE0ZjI2OGZiYzcucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI1MDYyMSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNTA2MjFUMjEzMDQ0WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9NmRiMmE3NzY3ZWIwYTcwZGJhY2NmZTNiNmJkMjk5MGJmYWZhZjUwZDczZDkxNjcxMzY2ZDBjZDk1Zjk0MTc2MyZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.ZGYH1j4pziLHFQzlKf98uVUxH2TuOMh7G9zmbrG9Utg))
  
</details>

<details>
  
  <summary>Click to reveal image of HTML Report</summary>
[![image](https://github.com/user-attachments/assets/41f627e4-5ffa-44c1-ab3c-b39fb1b818ba)](https://github.com/user-attachments/assets/41f627e4-5ffa-44c1-ab3c-b39fb1b818ba)

</details>



## 🌍 Donate to Charity Instead of Me

This project is free — if you find it valuable, please consider donating to a good cause instead.

Why? Because this project was built to help people, and there’s no better way to pay that forward than by supporting others in need. Whether it's providing clean water, funding medical aid, or fighting climate change, your donation can make a real difference.


### ✅ How It Works

1. **Donate directly** to any charity you care about (see suggestions below).
2. **Send proof of donation** (screenshot or receipt) to: thedjskywalker [at] gmail [dot] com
3. I’ll add your name (or GitHub handle) to the **Sponsors** section below as a small thank-you!

> 💡 I do not handle any money. Your donation goes **directly to the charity**.

---

### 🌍 Suggested Charities (Health & Climate)

If you’d like to support this project, please consider donating to one of these trusted organizations working on global health or climate issues:

#### 🏥 Health & Humanitarian Aid
- [**Doctors Without Borders**](https://donate.doctorswithoutborders.org/) – Emergency medical care in war zones and disaster areas.
- [**UNICEF**](https://help.unicef.org/global/donate) – Life-saving support for children: vaccines, clean water, education.
- [**World Central Kitchen**](https://wck.org/donate) – Meals for communities in crisis due to disaster or war.
- [**GiveWell – Top Charities Fund**](https://www.givewell.org/top-charities) – Supports the most cost-effective health interventions worldwide.

#### 🌱 Climate & Environment
- [**The Water Project**](https://thewaterproject.org/donate) – Clean water solutions for sub-Saharan African communities.
- [**Rainforest Alliance**](https://www.rainforest-alliance.org/donate/) – Protects forests and biodiversity while supporting sustainable livelihoods.
- [**Charity: Water**](https://www.charitywater.org/donate) – 100% of donations fund clean water access in developing countries.

> 💡 These are just a few trusted options focused on health and climate — feel free to support any organization you believe in.


## 🙌 Donor Recognition

Thank you to these generous supporters:

| Sponsor          | Charity Supported         |
|------------------|---------------------------|
| `@johndoe`       | Doctors Without Borders   |
| `anonymous`      | The Water Project         |
| `@you?`          | Your choice!              |

---

If you donate and want to be credited here, just let me know!



## 📝 Description

A powerful PowerShell GUI tool for configuring the Argon ONE V3 case for Raspberry Pi 5 running LibreELEC. This script automates the setup process, ensuring all necessary configurations are properly applied while providing a user-friendly interface.

## 🚀 Quick Start

### Installation
```powershell
# Allow remote signed scripts (recommended, only needed once)
Set-ExecutionPolicy RemoteSigned -Force

# Ensure NuGet provider is installed, then run the script
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser; Import-PackageProvider -Name NuGet -Force }; irm https://raw.githubusercontent.com/Nigel1992/Argonv3-RPI5-LibreELEC/main/argonv3.ps1 | iex
```

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🖥️ GUI Interface | Modern, intuitive graphical user interface |
| 💾 Config Backup | Creates backups of your settings |
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
