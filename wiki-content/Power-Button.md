# Power Button Configuration

This guide explains how to configure the power button functionality of your Argon ONE V3 case.

## Default Actions

| Action | Default Behavior | Customizable |
|--------|-----------------|--------------|
| Short Press | Sleep/Wake | ✅ Yes |
| Long Press | Shutdown | ✅ Yes |
| Double Press | Restart Kodi | ✅ Yes |

## Configuration Options

### Available Commands
- Shutdown
- Restart
- Sleep/Wake
- Restart Kodi
- Custom Command

### Custom Actions
You can assign custom commands to each button press type:
- System commands
- Kodi commands
- Script execution
- Multiple commands

## Setup Instructions

1. Open Configuration GUI
2. Go to "Power Button" section
3. Select desired actions
4. Test configuration
5. Save settings

## Advanced Features

### Custom Scripts
```powershell
# Example custom action
$customAction = {
    # Your custom commands here
    Restart-KodiService
    Start-Sleep -Seconds 5
    Send-Notification "Kodi Restarted"
}
```

### Safety Features
- Confirmation dialogs
- Command timeout
- Error handling
- State recovery

## Best Practices

1. Testing
   - Verify each action
   - Check timeout settings
   - Test error scenarios

2. Backup
   - Save configurations
   - Document custom scripts
   - Keep default settings

3. Safety
   - Use safe commands
   - Add confirmation dialogs
   - Include timeout values 