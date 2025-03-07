# Frequently Asked Questions

## General Questions

### Q: What does this script do?
A: This PowerShell script, together with the Argon Forty Addon, provides complete fan control and temperature monitoring for the Argon ONE V3 case on Raspberry Pi 5 running LibreELEC.

### Q: Do I need both the script and the addon?
A: Yes, you need both:
1. This PowerShell script for initial setup and configuration
2. The Argon Forty Addon for fan control and temperature monitoring
See the complete setup guide at [Reddit guide](https://www.reddit.com/r/libreELEC/comments/1hxsc2a/guide_how_to_make_the_argon_v3_work_flawlessly/)

### Q: What are the system requirements?
A: You need:
- Windows with PowerShell 5.1 or later
- Raspberry Pi 5
- Argon ONE V3 case
- LibreELEC installed
- Network connection

## Setup Questions

### Q: How do I run the script?
A: You can either:
1. Use the direct installation command:
```powershell
irm https://raw.githubusercontent.com/Nigel1992/Argonv3-RPI5-LibreELEC/main/argonv3.ps1 | iex
```
2. Or download and run manually from the releases page

### Q: Why does PowerShell block the script?
A: You need to allow remote signed scripts:
```powershell
Set-ExecutionPolicy RemoteSigned -Force
```

### Q: How do I find my Pi's IP address?
A: Check the LibreELEC settings menu under System Information.

## Troubleshooting

### Q: The script can't connect to my Pi
A: Check:
1. Pi is powered on and connected to network
2. IP address is correct
3. SSH is enabled in LibreELEC

### Q: Where are the log files?
A: Logs are stored in:
```plaintext
%USERPROFILE%\Documents\ArgonSetup\logs\
```

### Q: How do I report issues?
A: Open an issue on GitHub with:
1. Script version
2. Error message
3. Steps to reproduce
4. Log files 