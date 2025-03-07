# Troubleshooting Guide

This guide helps you resolve common issues with the Argon ONE V3 setup script.

## Common Issues

### Connection Problems

#### Cannot Connect to Pi
1. Check if Pi is powered on
2. Verify network connection
3. Confirm IP address
4. Test SSH connection manually
5. Check firewall settings

#### SSH Authentication Failed
1. Verify credentials
2. Check SSH service status
3. Reset SSH connection
4. Check for typos

### Script Issues

#### Script Won't Run
1. Check PowerShell version
```powershell
$PSVersionTable.PSVersion
```
2. Enable script execution
```powershell
Set-ExecutionPolicy RemoteSigned -Force
```
3. Unblock downloaded files
   - Right-click script
   - Properties
   - Check "Unblock"

#### Script Crashes
1. Check error message
2. Review logs
3. Verify permissions
4. Check available disk space

## Error Messages

### Common Error Messages

#### "Connection timed out"
- Check network connectivity
- Verify Pi is responsive
- Check IP address

#### "Access denied"
- Run PowerShell as Administrator
- Check file permissions
- Verify user rights

## Diagnostic Steps

### 1. Gather Information
- Script version
- PowerShell version
- Windows version
- Error messages
- Log files

### 2. Check Logs
```plaintext
%USERPROFILE%\Documents\ArgonSetup\logs\
```

### 3. Verify Environment
- Network connectivity
- System requirements
- Required permissions

## Getting Help

### Support Resources
1. Check [FAQ](FAQ.md)
2. Search GitHub Issues
3. Post in Discussions
4. Submit bug report

### Required Information
When seeking help, provide:
1. Error messages
2. Log files
3. Steps to reproduce
4. System details 