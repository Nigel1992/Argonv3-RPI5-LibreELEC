[![Discord](https://img.shields.io/discord/1468295714961494029?color=7289da&label=Join%20Our%20Discord&logo=discord&logoColor=white&style=for-the-badge)]([![Discord](https://img.shields.io/discord/1468295714961494029?color=7289da&label=Join%20Our%20Discord&logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/9F2NZuydXT))


[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Nigel1992)

# 🛠️ Argon ONE V3 Setup Script for LibreELEC on Raspberry Pi 5

[![Vibe Coded](https://img.shields.io/badge/Vibe_Coded-✨-8A2BE2?style=for-the-badge)](https://github.com)

[![Version](https://img.shields.io/badge/version-1.4.0.1-blue)](https://github.com/Nigel1992/Argonv3-RPI5-LibreELEC)
[![Platform](https://img.shields.io/badge/platform-LibreELEC-green)](https://libreelec.tv/)
[![RPi](https://img.shields.io/badge/device-Raspberry%20Pi%205-red)](https://www.raspberrypi.com/)
[![PowerShell](https://img.shields.io/badge/powershell-%3E%3D5.1-blue)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

<details>  
  <summary>Click to reveal image of GUI</summary>
  
![image](https://github.com/user-attachments/assets/56f4bb01-f9bc-49b9-9de4-7ba3f9f8ace2)

</details>

<details>  
  <summary>Click to reveal image of HTML Report</summary>
  
[![image](https://github.com/user-attachments/assets/41f627e4-5ffa-44c1-ab3c-b39fb1b818ba)](https://github.com/user-attachments/assets/41f627e4-5ffa-44c1-ab3c-b39fb1b818ba)

</details>

## 🆕 What's New in v1.4.0.1 (28/6/2025)

### 🔧 Bug Fixes
- **SSH Connection Issues**: Fixed SSH session creation in Test-CurrentSettings function
  - Now uses same robust connection method as Test-SSHConnection
  - Added fallback key exchange algorithms for better compatibility
  - Improved error handling with proper session validation
  - Auto-removes old host keys to prevent connection conflicts
- **EEPROM Detection**: Fixed false negative reports for existing EEPROM settings
  - Added missing rpi-eeprom-config file creation in test function
  - Ensures /tmp/current_eeprom.conf exists before checking settings
- **Path Construction**: Fixed Join-Path syntax error in known_hosts file handling

### 🚀 Improvements
- Enhanced error messages and user feedback
- Better SSH connection failure diagnostics
- Clear troubleshooting steps for connection issues
- Improved session validation with null checks

## 💖 Support the Project

I build this project in my free time and don't need donations for myself. If you'd like to give something back, I'd kindly ask you to donate to a charity of your choice instead — they need it far more than I do. If you still prefer to support me directly in private, thank you so much; it's genuinely appreciated, and I'll be happy to list you as a donor on GitHub and, where applicable, in a donors section of the project, as a small thank you.

[![Ko-Fi](https://img.shields.io/badge/Ko--Fi-Support%20me-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/nigel1992)
[![PayPal](https://img.shields.io/badge/PayPal-Donate-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=KYV9ARF99ZSCE)
