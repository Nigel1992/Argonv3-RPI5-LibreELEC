# Setup Guide

This guide will walk you through the complete setup process for the Argon ONE V3 case with LibreELEC on Raspberry Pi 5.

## Prerequisites

### Hardware Requirements
- Raspberry Pi 5
- Argon ONE V3 case
- Network connection to your Pi

### Software Requirements
- Windows PC with PowerShell 5.1 or later
- LibreELEC installed on your Pi
- Administrator privileges on your Windows PC

## Installation Steps

### 1. Prepare Your System

1. Install LibreELEC on your Raspberry Pi 5
2. Note down your Pi's IP address from LibreELEC settings
3. Make sure SSH is enabled in LibreELEC services

### 2. Run the PowerShell Script

#### Option 1: Direct Installation (Recommended)
```powershell
# Allow remote signed scripts (if not already done)
Set-ExecutionPolicy RemoteSigned -Force

# Run the script
irm https://raw.githubusercontent.com/Nigel1992/Argonv3-RPI5-LibreELEC/main/argonv3.ps1 | iex
```

#### Option 2: Manual Installation
1. Download the script from our [releases page](../releases)
2. Right-click the downloaded script
3. Select "Properties" and check "Unblock"
4. Right-click and select "Run with PowerShell"

### 3. Install Argon Forty Addon

Follow the complete addon installation guide at:
[Reddit Guide: How to make the Argon V3 work flawlessly](https://www.reddit.com/r/libreELEC/comments/1hxsc2a/guide_how_to_make_the_argon_v3_work_flawlessly/)

### 4. Verify Installation

After setup:
1. Confirm script completed successfully
2. Verify addon is installed and working
3. Test fan control through addon
4. Check temperature monitoring

## Configuration

### Basic Settings
- Network connection
- SSH access
- Initial setup options
- Basic configuration

### Advanced Options
- Custom configurations
- Additional features
- Performance settings

## Next Steps

1. Configure [Fan Control](Fan-Control.md)
2. Set up [Power Button](Power-Button.md)
3. Review [FAQ](FAQ.md) for common questions
4. Check [Troubleshooting](Troubleshooting.md) if needed 