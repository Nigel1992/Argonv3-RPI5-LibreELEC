# Script Configuration

This guide explains how to configure and customize the setup script for your Argon ONE V3 case.

## Basic Configuration

### Connection Settings
- LibreELEC IP address
- SSH credentials
- Connection timeout
- Retry settings

### Display Options
- Interface language
- Theme selection
- Window size
- Dialog preferences

### Logging Options
- Log file location
- Log retention period
- Detail level
- Export format

## Advanced Settings

### Setup Configuration
```powershell
# Example configuration
$setupConfig = @{
    SSHTimeout = 30        # Seconds
    RetryAttempts = 3      # Connection retries
    LogLevel = "Detailed"  # Logging detail
    BackupSettings = $true # Backup current settings
}
```

### Backup Settings
- Configuration backup
- Restore points
- Export settings
- Import settings

## GUI Customization

### Theme Options
- Dark/Light mode
- Custom colors
- Font settings
- Window size

### Display Elements
- Progress indicators
- Status messages
- Dialog boxes
- Tooltips

## Script Locations

### Default Paths
```plaintext
%USERPROFILE%\Documents\ArgonSetup\
├── config\
│   └── settings.xml        # Script settings
├── logs\
│   └── setup_*.log        # Setup logs
└── backup\
    └── config_*.bak       # Configuration backups
```

## Best Practices

1. Configuration
   - Backup settings regularly
   - Document custom changes
   - Test after modifications

2. Setup Process
   - Verify connections
   - Follow prompts carefully
   - Keep logs for reference

3. Maintenance
   - Regular script updates
   - Clean old logs
   - Maintain backups 