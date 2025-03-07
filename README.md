# Argon V3 LibreELEC Setup Tool

A PowerShell-based configuration tool for Argon V3 cases running LibreELEC on Raspberry Pi 5.

## Version 1.2.2 (March 7, 2025)

### New Features & Improvements
- Added "Test Current Settings" functionality with HTML report generation
- Improved settings display with a clean, modern HTML layout
- Implemented per-session log files with timestamps
- Added "Show Log" button to view current session's log file
- Reduced progress bar size for a cleaner interface
- Enhanced error handling and user feedback

### Technical Changes
- Log files are now stored in `Documents\ArgonSetup\logs` with timestamps
- Configuration test results are displayed in a formatted HTML page
- Progress bar height reduced to 12 pixels for better aesthetics
- Improved theme handling for both light and dark modes

## Requirements
- Windows 10/11
- PowerShell 5.1 or later
- Posh-SSH module (automatically installed if missing)
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
