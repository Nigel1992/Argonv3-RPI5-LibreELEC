# Setup Guide

This guide will walk you through using our PowerShell script to configure your Argon ONE V3 case with LibreELEC on Raspberry Pi 5.

## Prerequisites

### Hardware Requirements
- Raspberry Pi 5 with LibreELEC already installed
- Argon ONE V3 case
- Network connection to your Pi

### Software Requirements
- Windows PC with PowerShell 5.1 or later
- Administrator privileges on your Windows PC
- Network access to your LibreELEC device

## Setup Steps

### 1. Prepare Your System

1. Ensure LibreELEC is installed and running on your Pi
2. Note down your Pi's IP address from LibreELEC settings
3. Make sure SSH is enabled in LibreELEC services

### 2. Download and Run the Script

#### Option 1: Direct Installation (Recommended)
```powershell
# Allow remote signed scripts (if not already done)
Set-ExecutionPolicy RemoteSigned -Force

# Run the script
irm https://raw.githubusercontent.com/Nigel1992/Argonv3-RPI5-LibreELEC/main/argonv3.ps1 | iex
```

#### Option 2: Manual Installation
1. Download the script from our [Releases page](../releases)
2. Right-click the downloaded script
3. Select "Properties" and check "Unblock"
4. Right-click and select "Run with PowerShell"

### 3. Initial Configuration

1. Enter your LibreELEC device's IP address
2. Verify the connection (default credentials: root/libreelec)
3. Select your configuration options:
   - Fan control settings
   - Power button behavior
   - Temperature thresholds
   - Additional features

### 4. Verify Installation

After configuration:
1. Test the fan control
2. Verify power button functionality
3. Check temperature readings
4. Review the configuration log

## Configuration Options

### Fan Control
- Temperature-based speed control
- Custom fan curves
- Manual speed override
- Silent mode options

### Power Button
- Short press action
- Long press action
- Double press action
- Custom commands

### Advanced Settings
- Temperature monitoring interval
- Logging options
- Debug mode
- Custom scripts

## Troubleshooting

If you encounter issues:

1. Check network connectivity
2. Verify LibreELEC SSH access
3. Review PowerShell execution policy
4. Check the [Troubleshooting Guide](Troubleshooting)

## Next Steps

- [Configure Fan Control](Fan-Control)
- [Customize Power Button](Power-Button)
- [Advanced Configuration](Advanced-Config) 