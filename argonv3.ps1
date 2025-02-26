# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define theme colors
$THEME_PRIMARY = [System.Drawing.Color]::FromArgb(0, 120, 212)     # Microsoft Blue
$THEME_SECONDARY = [System.Drawing.Color]::FromArgb(45, 45, 45)    # Dark Gray
$THEME_TEXT = [System.Drawing.Color]::FromArgb(250, 250, 250)      # Almost White

# Get the script's directory
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
if ([string]::IsNullOrEmpty($PSScriptRoot)) {
    $PSScriptRoot = "$env:USERPROFILE\Documents\ArgonSetup"
    New-Item -ItemType Directory -Force -Path $PSScriptRoot | Out-Null
}

# Set file paths
$SETTINGS_FILE = Join-Path $PSScriptRoot "argon_settings.xml"
$CONNECTION_FILE = Join-Path $PSScriptRoot "connection_settings.xml"
$SCRIPT_VERSION = "1.2.0 (02/26/2024)"

# Get screen working area (accounts for taskbar)
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$maxHeight = $screen.Height
$defaultHeight = 850  # Default form height
$expandedHeight = 800 # Height when log is shown

# Adjust heights if they exceed screen size
if ($defaultHeight -gt $maxHeight) {
    $defaultHeight = $maxHeight - 50  # Leave some margin
}
if ($expandedHeight -gt $maxHeight) {
    $expandedHeight = $maxHeight - 50
}

# Define functions first
function Log-Message {
    param(
        [string]$Message,
        [string]$Type = "INFO"  # INFO, SUCCESS, ERROR, WARNING, CONFIG
    )
    
    $timestamp = Get-Date -Format "[HH:mm:ss]"
    $logMessage = "$timestamp '$Type': $Message"
    $logBox.AppendText("$logMessage`r`n")
    $logBox.ScrollToCaret()
}

function Test-SSHConnection {
    try {
        $securePass = ConvertTo-SecureString $passTextBox.Text -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($userTextBox.Text, $securePass)
        
        Log-Message "Testing connection to $($ipTextBox.Text)..." "INFO"
        
        $session = New-SSHSession -ComputerName $ipTextBox.Text -Credential $cred -AcceptKey -ErrorAction Stop
        if ($session) {
            Log-Message "Connection successful!" "SUCCESS"
            Remove-SSHSession -SessionId $session.SessionId

            # Save only connection settings
            $connectionSettings = @{
                IP = $ipTextBox.Text
                Username = $userTextBox.Text
                Password = $passTextBox.Text
            }

            # Save connection settings to file
            try {
                Export-Clixml -Path $CONNECTION_FILE -InputObject $connectionSettings -Force
                Log-Message "Connection settings saved" "SUCCESS"
            }
            catch {
                Log-Message "Warning: Could not save connection settings - $($_.Exception.Message)" "WARNING"
            }

            # Success message
            $successMessage = @"
Connection successful!

Your connection settings have been saved:
- IP Address: $($ipTextBox.Text)
- Username: $($userTextBox.Text)
- Password: ********

You can now proceed with applying the configuration.
"@

            [System.Windows.Forms.MessageBox]::Show(
                $successMessage,
                "Connection Successful",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            
            return $true
        }
    }
    catch {
        Log-Message "Connection failed: $($_.Exception.Message)" "ERROR"
        
        $sshInstructions = @"
Unable to establish SSH connection. Please follow these steps:

1. Enable SSH in LibreELEC:
   - Open Kodi
   - Go to Add-ons
   - Select 'LibreELEC Configuration'
   - Navigate to 'Services'
   - Enable 'Start SSH server at boot'
   - Reboot LibreELEC

2. Verify your credentials:
   - Default username: root
   - Default password: libreelec

3. Check your connection:
   - Make sure the IP address is correct
   - Verify LibreELEC's IP in Kodi: System → System info → Network
   - Ensure your PC and LibreELEC are on the same network
   - Check that no firewall is blocking port 22

Need help? Visit the LibreELEC SSH guide online.
"@

        [System.Windows.Forms.MessageBox]::Show(
            $sshInstructions,
            "Connection Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        return $false
    }
}

function Update-Progress {
    param(
        [int]$PercentComplete,
        [string]$Status
    )
    
    $configProgress.Value = $PercentComplete
    $progressLabel.Text = "$Status ($PercentComplete%)"
    
    # Smooth animation
    $form.Refresh()
    Start-Sleep -Milliseconds 50
}

function Create-Backup {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SessionId,
        [string]$FilePath,
        [string]$FileType
    )
    
    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $fileName = Split-Path $FilePath -Leaf
        $backupDir = "/storage/ArgonScriptBackup"
        $backupPath = "$backupDir/$fileName.backup_$timestamp"
        
        # Verbose logging for debugging
        Log-Message "Attempting to backup $FilePath to $backupPath" "INFO"
        
        # First check if source file exists
        $checkSource = Invoke-SSHCommand -SessionId $SessionId -Command "ls -l '$FilePath'"
        if ($checkSource.ExitStatus -ne 0) {
            Log-Message "Source file not found: $FilePath" "ERROR"
            return $false
        }
        Log-Message ("Source file check: " + $checkSource.Output) "INFO"

        # Then do the copy
        $copyCommand = Invoke-SSHCommand -SessionId $SessionId -Command "cp '$FilePath' '$backupPath'"
        if ($copyCommand.ExitStatus -ne 0) {
            Log-Message ("Copy failed: " + $copyCommand.Error) "ERROR"
            return $false
        }

        # Set permissions if copy succeeded
        $chmodCommand = Invoke-SSHCommand -SessionId $SessionId -Command "chmod 644 '$backupPath'"
        if ($chmodCommand.ExitStatus -ne 0) {
            Log-Message "Warning: Could not set permissions on backup file" "WARNING"
        }

        # Verify backup exists
        $verifyBackup = Invoke-SSHCommand -SessionId $SessionId -Command "ls -l '$backupPath'"
        if ($verifyBackup.ExitStatus -eq 0) {
            Log-Message "Created backup of $FileType at: $backupPath" "SUCCESS"
            Log-Message ("Backup file details: " + $verifyBackup.Output) "INFO"
            return $true
        } else {
            Log-Message "Backup file was not created" "ERROR"
            return $false
        }
    }
    catch {
        Log-Message ("Error creating backup of " + $FileType + ": " + $_.Exception.Message) "ERROR"
        return $false
    }
}

function Apply-Configuration {
    if (-not (Test-SSHConnection)) {
        return
    }

    # Ask user about backup
    $backupResult = [System.Windows.Forms.MessageBox]::Show(
        "Would you like to create backups of your configuration files before making changes?`n`nBackups will be saved in /storage/ArgonScriptBackup with timestamps.",
        "Create Backup?",
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($backupResult -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Log-Message "Configuration cancelled by user" "INFO"
        return
    }

    try {
        # Create SSH session
        $securePass = ConvertTo-SecureString $passTextBox.Text -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($userTextBox.Text, $securePass)
        $session = New-SSHSession -ComputerName $ipTextBox.Text -Credential $cred -AcceptKey

        # If user wanted backups, create directory and backups
        if ($backupResult -eq [System.Windows.Forms.DialogResult]::Yes) {
            Update-Progress -PercentComplete 5 -Status "Setting up backup directory"
            Log-Message "Preparing backup location..." "INFO"

            # Create backup directory with verbose output
            $createDirScript = @'
#!/bin/sh
set -x
if [ ! -d "/storage/ArgonScriptBackup" ]; then
    mkdir -p "/storage/ArgonScriptBackup"
    MKDIR_STATUS=$?
    echo "Directory creation status: $MKDIR_STATUS"
    
    chmod 755 "/storage/ArgonScriptBackup"
    CHMOD_STATUS=$?
    echo "Chmod status: $CHMOD_STATUS"
    
    chown root:root "/storage/ArgonScriptBackup"
    CHOWN_STATUS=$?
    echo "Chown status: $CHOWN_STATUS"
    
    if [ $MKDIR_STATUS -eq 0 ] && [ $CHMOD_STATUS -eq 0 ] && [ $CHOWN_STATUS -eq 0 ]; then
        echo "Backup directory created and configured successfully"
        ls -la "/storage/ArgonScriptBackup"
        exit 0
    else
        echo "Failed to setup backup directory"
        exit 1
    fi
else
    echo "Backup directory already exists"
    ls -la "/storage/ArgonScriptBackup"
    exit 0
fi
'@

            $createDirResult = Invoke-SSHCommand -SessionId $session.SessionId -Command $createDirScript

            Log-Message ("Directory creation output: " + $createDirResult.Output) "INFO"
            Log-Message ("Directory creation error: " + $createDirResult.Error) "INFO"

            if ($createDirResult.ExitStatus -ne 0) {
                $continueResult = [System.Windows.Forms.MessageBox]::Show(
                    "Failed to create backup directory. Do you want to continue without backups?",
                    "Backup Directory Error",
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
                if ($continueResult -eq [System.Windows.Forms.DialogResult]::No) {
                    Log-Message "Configuration cancelled due to backup directory creation failure" "WARNING"
                    Update-Progress -PercentComplete 0 -Status "Ready"
                    return
                }
                Log-Message "Continuing without backups" "WARNING"
            } else {
                Update-Progress -PercentComplete 10 -Status "Creating backups"
                Log-Message "Creating configuration backups..." "INFO"

                # Mount flash directory as writable
                Invoke-SSHCommand -SessionId $session.SessionId -Command "mount -o remount,rw /flash"

                # Create backups
                $backupSuccess = $true
                $backupSuccess = $backupSuccess -and (Create-Backup -SessionId $session.SessionId -FilePath "/flash/config.txt" -FileType "config file")
                $backupSuccess = $backupSuccess -and (Create-Backup -SessionId $session.SessionId -FilePath "/tmp/current_eeprom.conf" -FileType "EEPROM configuration")

                if (-not $backupSuccess) {
                    $continueResult = [System.Windows.Forms.MessageBox]::Show(
                        "Failed to create some backups. Do you want to continue anyway?",
                        "Backup Warning",
                        [System.Windows.Forms.MessageBoxButtons]::YesNo,
                        [System.Windows.Forms.MessageBoxIcon]::Warning
                    )
                    if ($continueResult -eq [System.Windows.Forms.DialogResult]::No) {
                        Log-Message "Configuration cancelled by user due to backup failure" "WARNING"
                        Update-Progress -PercentComplete 0 -Status "Ready"
                        return
                    }
                } else {
                    [System.Windows.Forms.MessageBox]::Show(
                        "Backups created successfully!`n`nLocation: /storage/ArgonScriptBackup`n`nYou can find your backups there with timestamps for easy identification.",
                        "Backup Success",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                    Log-Message "Backups created successfully in /storage/ArgonScriptBackup" "SUCCESS"
                }
            }
        } else {
            Log-Message "User chose to skip backups" "INFO"
        }

        # Continue with configuration
        Update-Progress -PercentComplete 20 -Status "Checking current configuration"
        Log-Message "Checking current configuration..." "INFO"
        
        # Check if any changes are needed
        Update-Progress -PercentComplete 30 -Status "Mounting system"
        Invoke-SSHCommand -SessionId $session.SessionId -Command "mount -o remount,rw /flash"
        Log-Message "Checking current settings..." "INFO"

        # Common config settings
        Update-Progress -PercentComplete 40 -Status "Checking config settings"
        $configSettings = @(
            "dtoverlay=gpio-ir,gpio_pin=23",
            "dtparam=i2c=on",
            "enable_uart=1",
            "usb_max_current_enable=1"
        )

        # Add NVMe settings if applicable
        if ($versionCombo.SelectedItem -eq "Argon V3 with NVMe") {
            $pcieGen = switch ($pcieCombo.SelectedItem) {
                "Gen 1" { "gen1" }
                "Gen 2" { "gen2" }
                "Gen 3" { "gen3" }
            }
            $configSettings += "dtparam=nvme"
            $configSettings += "dtparam=pciex1_1=$pcieGen"
        }

        # Add DAC settings if applicable
        if ($dacCheckbox.Checked) {
            $configSettings += "dtoverlay=hifiberry-dacplus,slave"
        }

        # Check existing config settings
        Update-Progress -PercentComplete 50 -Status "Verifying current configuration"
        $missingSettings = @()
        foreach ($setting in $configSettings) {
            $checkResult = Invoke-SSHCommand -SessionId $session.SessionId -Command "grep -qF -- `"$setting`" /flash/config.txt"
            if ($checkResult.ExitStatus -ne 0) {
                $missingSettings += $setting
                $configChanged = $true
            } else {
                Log-Message "Setting already exists: $setting" "INFO"
            }
        }

        # Check EEPROM configuration
        Update-Progress -PercentComplete 60 -Status "Checking EEPROM settings"
        Invoke-SSHCommand -SessionId $session.SessionId -Command "rpi-eeprom-config > /tmp/current_eeprom.conf"
        
        # Set EEPROM updates based on version
        $missingEepromUpdates = @()
        $eepromUpdates = if ($versionCombo.SelectedItem -eq "Argon V3 Normal") {
            @("PSU_MAX_CURRENT=5000")
        } else {
            @(
                "BOOT_ORDER=0xf416",
                "PCIE_PROBE=1",
                "PSU_MAX_CURRENT=5000"
            )
        }

        # Check existing EEPROM settings
        foreach ($update in $eepromUpdates) {
            $setting = $update.Split('=')[0]
            $value = $update.Split('=')[1]
            $checkResult = Invoke-SSHCommand -SessionId $session.SessionId -Command "grep -w `"^$setting`" /tmp/current_eeprom.conf"
            if ($checkResult.Output -ne $update) {
                $missingEepromUpdates += $update
                $eepromChanged = $true
            } else {
                Log-Message "EEPROM setting already exists: $update" "INFO"
            }
        }

        # If no changes needed, inform user and exit
        if (-not $configChanged -and -not $eepromChanged) {
            Update-Progress -PercentComplete 100 -Status "Already configured"
            Log-Message "All required settings are already configured correctly" "SUCCESS"
            [System.Windows.Forms.MessageBox]::Show(
                "All required settings are already configured correctly. No changes needed.",
                "Configuration Check",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            Start-Sleep -Seconds 3
            Update-Progress -PercentComplete 0 -Status "Ready"
            return
        }

        # Show summary and ask for confirmation
        $summary = "The following changes will be made:`n`n"
        if ($missingSettings.Count -gt 0) {
            $summary += "Config.txt additions:`n"
            $summary += $missingSettings -join "`n"
            $summary += "`n`n"
        }
        if ($missingEepromUpdates.Count -gt 0) {
            $summary += "EEPROM updates:`n"
            $summary += $missingEepromUpdates -join "`n"
        }
        
        $result = [System.Windows.Forms.MessageBox]::Show(
            "$summary`n`nDo you want to apply these changes?",
            "Confirm Changes",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($result -eq [System.Windows.Forms.DialogResult]::No) {
            Log-Message "Configuration cancelled by user" "INFO"
            return
        }

        # Apply missing config settings
        Update-Progress -PercentComplete 70 -Status "Applying configuration changes"
        foreach ($setting in $missingSettings) {
            Invoke-SSHCommand -SessionId $session.SessionId -Command "echo `"$setting`" >> /flash/config.txt"
            Log-Message "Added setting: $setting" "SUCCESS"
        }

        # Apply missing EEPROM updates
        if ($missingEepromUpdates.Count -gt 0) {
            $eepromScript = $missingEepromUpdates -join "`n"
            Invoke-SSHCommand -SessionId $session.SessionId -Command @"
echo '$eepromScript' > /tmp/boot.conf
rpi-eeprom-config -a /tmp/boot.conf
rm /tmp/boot.conf
"@
            Log-Message "Updated EEPROM settings" "SUCCESS"
        }

        # Cleanup
        Invoke-SSHCommand -SessionId $session.SessionId -Command @"
rm /tmp/current_eeprom.conf
mount -o remount,ro /flash
"@

        # Save all settings
        $allSettings = @{
            IP = $ipTextBox.Text
            Username = $userTextBox.Text
            Password = $passTextBox.Text
            Version = $versionCombo.SelectedItem
            PCIe = $pcieCombo.SelectedItem
            DAC = $dacCheckbox.Checked
        }
        Export-Clixml -Path $SETTINGS_FILE -InputObject $allSettings -Force
        Log-Message "All settings saved successfully" "SUCCESS"

        # Ask for reboot only if changes were made
        $rebootResult = [System.Windows.Forms.MessageBox]::Show(
            "Configuration has been applied successfully! A reboot is required for changes to take effect. Would you like to reboot now?",
            "Configuration Complete",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($rebootResult -eq [System.Windows.Forms.DialogResult]::Yes) {
            Log-Message "Rebooting device..." "INFO"
            Invoke-SSHCommand -SessionId $session.SessionId -Command "reboot"
        } else {
            Log-Message "Reboot skipped. Please remember to reboot your device later." "WARNING"
        }
        
        Update-Progress -PercentComplete 100 -Status "Configuration complete"
        Log-Message "Configuration completed successfully" "SUCCESS"
        [System.Windows.Forms.MessageBox]::Show(
            "Configuration has been applied successfully! A reboot is required for changes to take effect.",
            "Configuration Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        Start-Sleep -Seconds 3
        Update-Progress -PercentComplete 0 -Status "Ready"
    }
    catch {
        Update-Progress -PercentComplete 0 -Status "Configuration failed"
        Log-Message "Failed to apply configuration: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to apply configuration. Please check the log for details.",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    finally {
        if ($session) {
            # Remount as read-only before closing
            Invoke-SSHCommand -SessionId $session.SessionId -Command "mount -o remount,ro /flash"
            Remove-SSHSession -SessionId $session.SessionId
        }
    }
}

# Function to load settings when the program starts
function Load-SavedSettings {
    # Load connection settings first
    if (Test-Path $CONNECTION_FILE) {
        try {
            $connectionSettings = Import-Clixml -Path $CONNECTION_FILE
            
            $ipTextBox.Text = $connectionSettings.IP
            $userTextBox.Text = $connectionSettings.Username
            $passTextBox.Text = $connectionSettings.Password
            
            Log-Message "Connection settings loaded" "INFO"
        }
        catch {
            Log-Message "Could not load connection settings - $($_.Exception.Message)" "WARNING"
        }
    }

    # Load all settings if they exist
    if (Test-Path $SETTINGS_FILE) {
        try {
            $allSettings = Import-Clixml -Path $SETTINGS_FILE
            
            # Connection settings will be overwritten if they exist in both files
            $ipTextBox.Text = $allSettings.IP
            $userTextBox.Text = $allSettings.Username
            $passTextBox.Text = $allSettings.Password
            
            if ($allSettings.Version -and $versionCombo.Items.Contains($allSettings.Version)) {
                $versionCombo.SelectedItem = $allSettings.Version
            }
            
            if ($allSettings.PCIe -and $pcieCombo.Items.Contains($allSettings.PCIe)) {
                $pcieCombo.SelectedItem = $allSettings.PCIe
            }
            
            $dacCheckbox.Checked = $allSettings.DAC
            
            Log-Message "All settings loaded successfully" "INFO"
        }
        catch {
            Log-Message "Could not load all settings - $($_.Exception.Message)" "WARNING"
        }
    }
}

# Now continue with your existing UI code
# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Argon V3 - LibreELEC Setup"
$form.Size = New-Object System.Drawing.Size(800, $defaultHeight)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::White
$form.MaximumSize = New-Object System.Drawing.Size(1200, $maxHeight)
$form.MinimumSize = New-Object System.Drawing.Size(800, 500)
$form.MaximizeBox = $false  # Disable maximize button
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle  # Prevent resizing

# Create main TableLayoutPanel
$mainLayout = New-Object System.Windows.Forms.TableLayoutPanel
$mainLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainLayout.ColumnCount = 1
$mainLayout.RowCount = 4
$mainLayout.Padding = New-Object System.Windows.Forms.Padding(20)
$mainLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))

# Set row heights
$mainLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 80))) # Header
$mainLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 150))) # Connection
$mainLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 150))) # Config
$mainLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) # Log and buttons

# Header Panel
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.BackColor = $THEME_PRIMARY
$headerPanel.Dock = [System.Windows.Forms.DockStyle]::Fill

$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "Argon V3 - LibreELEC Setup"
$headerLabel.ForeColor = [System.Drawing.Color]::White
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$headerLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$headerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

$headerPanel.Controls.Add($headerLabel)
$mainLayout.Controls.Add($headerPanel, 0, 0)

# Connection Group
$connectionGroup = New-Object System.Windows.Forms.GroupBox
$connectionGroup.Text = "Connection Settings"
$connectionGroup.Dock = [System.Windows.Forms.DockStyle]::Fill
$connectionGroup.Font = New-Object System.Drawing.Font("Segoe UI", 11)

# Connection Controls
$ipLabel = New-Object System.Windows.Forms.Label
$ipLabel.Text = "IP Address:"
$ipLabel.Location = New-Object System.Drawing.Point(20, 30)
$ipLabel.AutoSize = $true

$ipTextBox = New-Object System.Windows.Forms.TextBox
$ipTextBox.Location = New-Object System.Drawing.Point(150, 30)
$ipTextBox.Size = New-Object System.Drawing.Size(200, 25)

$userLabel = New-Object System.Windows.Forms.Label
$userLabel.Text = "Username:"
$userLabel.Location = New-Object System.Drawing.Point(20, 65)
$userLabel.AutoSize = $true

$userTextBox = New-Object System.Windows.Forms.TextBox
$userTextBox.Location = New-Object System.Drawing.Point(150, 65)
$userTextBox.Size = New-Object System.Drawing.Size(200, 25)
$userTextBox.Text = "root"

$passLabel = New-Object System.Windows.Forms.Label
$passLabel.Text = "Password:"
$passLabel.Location = New-Object System.Drawing.Point(20, 100)
$passLabel.AutoSize = $true

$passTextBox = New-Object System.Windows.Forms.TextBox
$passTextBox.Location = New-Object System.Drawing.Point(150, 100)
$passTextBox.Size = New-Object System.Drawing.Size(200, 25)
$passTextBox.PasswordChar = '*'
$passTextBox.Text = "libreelec"

$testButton = New-Object System.Windows.Forms.Button
$testButton.Text = "Test Connection"
$testButton.Location = New-Object System.Drawing.Point(400, 30)
$testButton.Size = New-Object System.Drawing.Size(150, 30)
$testButton.BackColor = $THEME_PRIMARY
$testButton.ForeColor = [System.Drawing.Color]::White
$testButton.Add_Click({ Test-SSHConnection })

$connectionGroup.Controls.AddRange(@($ipLabel, $ipTextBox, $userLabel, $userTextBox, $passLabel, $passTextBox, $testButton))
$mainLayout.Controls.Add($connectionGroup, 0, 1)

# Config Group
$configGroup = New-Object System.Windows.Forms.GroupBox
$configGroup.Text = "Argon Configuration"
$configGroup.Dock = [System.Windows.Forms.DockStyle]::Fill
$configGroup.Font = New-Object System.Drawing.Font("Segoe UI", 11)

# Config Controls
$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "Argon Version:"
$versionLabel.Location = New-Object System.Drawing.Point(20, 30)
$versionLabel.AutoSize = $true

$versionCombo = New-Object System.Windows.Forms.ComboBox
$versionCombo.Location = New-Object System.Drawing.Point(150, 30)
$versionCombo.Size = New-Object System.Drawing.Size(200, 25)
$versionCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$versionCombo.Items.AddRange(@("Argon V3 Normal", "Argon V3 with NVMe"))

$pcieLabel = New-Object System.Windows.Forms.Label
$pcieLabel.Text = "PCIe Generation:"
$pcieLabel.Location = New-Object System.Drawing.Point(400, 30)
$pcieLabel.AutoSize = $true

$pcieCombo = New-Object System.Windows.Forms.ComboBox
$pcieCombo.Location = New-Object System.Drawing.Point(530, 30)
$pcieCombo.Size = New-Object System.Drawing.Size(150, 25)
$pcieCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$pcieCombo.Items.AddRange(@("Gen 1", "Gen 2", "Gen 3"))

$dacCheckbox = New-Object System.Windows.Forms.CheckBox
$dacCheckbox.Text = "Enable Argon Hi-Fi DAC"
$dacCheckbox.Location = New-Object System.Drawing.Point(400, 65)
$dacCheckbox.AutoSize = $true

$configGroup.Controls.AddRange(@($versionLabel, $versionCombo, $pcieLabel, $pcieCombo, $dacCheckbox))
$mainLayout.Controls.Add($configGroup, 0, 2)

# Bottom Panel (Buttons and Hidden Log)
$bottomPanel = New-Object System.Windows.Forms.TableLayoutPanel
$bottomPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$bottomPanel.ColumnCount = 1
$bottomPanel.RowCount = 4  # Changed to 4 to add progress bar row
$bottomPanel.Padding = New-Object System.Windows.Forms.Padding(10)

# Progress Panel
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$progressPanel.Height = 40
$progressPanel.Padding = New-Object System.Windows.Forms.Padding(20, 5, 20, 5)

# Progress Bar Container (for layering)
$progressContainer = New-Object System.Windows.Forms.Panel
$progressContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
$progressContainer.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$progressContainer.Padding = New-Object System.Windows.Forms.Padding(0)

# Progress Bar
$configProgress = New-Object System.Windows.Forms.ProgressBar
$configProgress.Size = New-Object System.Drawing.Size(700, 25)
$configProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$configProgress.Value = 0
$configProgress.Dock = [System.Windows.Forms.DockStyle]::Fill
$configProgress.ForeColor = $THEME_PRIMARY
$configProgress.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)

# Progress Label (overlaid on progress bar)
$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Text = "Ready"
$progressLabel.BackColor = [System.Drawing.Color]::Transparent
$progressLabel.ForeColor = [System.Drawing.Color]::White
$progressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$progressLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$progressLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$progressLabel.UseCompatibleTextRendering = $true

# Add controls to container
$progressContainer.Controls.Add($configProgress)
$progressContainer.Controls.Add($progressLabel)
$progressPanel.Controls.Add($progressContainer)

# Set row styles
$bottomPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 50))) # Apply button
$bottomPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 40))) # Show Log button
$bottomPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 40))) # Progress bar
$bottomPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) # Log

# Apply Button Panel
$applyButtonPanel = New-Object System.Windows.Forms.Panel
$applyButtonPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$applyButtonPanel.Height = 50

# Apply Button
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "Apply Configuration"
$applyButton.Size = New-Object System.Drawing.Size(150, 30)
$applyButton.BackColor = $THEME_PRIMARY
$applyButton.ForeColor = [System.Drawing.Color]::White
$applyButton.Add_Click({ Apply-Configuration })

# Center the Apply button
$applyButtonPanel.Controls.Add($applyButton)
$applyButtonPanel.Add_Resize({
    $applyButton.Left = ($applyButtonPanel.Width - $applyButton.Width) / 2
    $applyButton.Top = ($applyButtonPanel.Height - $applyButton.Height) / 2
})

# Show Log Button Panel
$showLogButtonPanel = New-Object System.Windows.Forms.Panel
$showLogButtonPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$showLogButtonPanel.Height = 40

# Show Log Button
$showLogButton = New-Object System.Windows.Forms.Button
$showLogButton.Text = "Show Log"
$showLogButton.Size = New-Object System.Drawing.Size(100, 25)
$showLogButton.BackColor = $THEME_SECONDARY
$showLogButton.ForeColor = [System.Drawing.Color]::White

# Center the Show Log button
$showLogButtonPanel.Controls.Add($showLogButton)
$showLogButtonPanel.Add_Resize({
    $showLogButton.Left = ($showLogButtonPanel.Width - $showLogButton.Width) / 2
    $showLogButton.Top = ($showLogButtonPanel.Height - $showLogButton.Height) / 2
})

# Log Box (hidden by default)
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$logBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$logBox.ReadOnly = $true
$logBox.Visible = $false

# Add controls to bottom panel
$bottomPanel.Controls.Add($applyButtonPanel, 0, 0)
$bottomPanel.Controls.Add($showLogButtonPanel, 0, 1)
$bottomPanel.Controls.Add($progressPanel, 0, 2)
$bottomPanel.Controls.Add($logBox, 0, 3)

# Toggle log visibility
$showLogButton.Add_Click({
    if ($logBox.Visible) {
        $logBox.Visible = $false
        $showLogButton.Text = "Show Log"
        $form.Height = $defaultHeight
    } else {
        $logBox.Visible = $true
        $showLogButton.Text = "Hide Log"
        $newHeight = [Math]::Min($expandedHeight, $maxHeight)
        $form.Height = $newHeight
    }
})

$mainLayout.Controls.Add($bottomPanel, 0, 3)

# Footer Panel
$footerPanel = New-Object System.Windows.Forms.Panel
$footerPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$footerPanel.Height = 30
$footerPanel.BackColor = $THEME_SECONDARY

# Create a TableLayoutPanel for better control
$footerLayout = New-Object System.Windows.Forms.TableLayoutPanel
$footerLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$footerLayout.RowCount = 1
$footerLayout.ColumnCount = 3
$footerLayout.Padding = New-Object System.Windows.Forms.Padding(5, 0, 5, 0)

# Set column styles
$footerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 25)))
$footerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)))
$footerLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 25)))

# Empty left column for balance
$leftLabel = New-Object System.Windows.Forms.Label
$footerLayout.Controls.Add($leftLabel, 0, 0)

# Copyright Label (center column)
$copyrightLabel = New-Object System.Windows.Forms.Label
$copyrightLabel.Text = "Made with <3 by Nigel Hagen"
$copyrightLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$copyrightLabel.ForeColor = $THEME_TEXT
$copyrightLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$copyrightLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$footerLayout.Controls.Add($copyrightLabel, 1, 0)

# Version Label (right column)
$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "v$SCRIPT_VERSION"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$versionLabel.ForeColor = $THEME_TEXT
$versionLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$versionLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$footerLayout.Controls.Add($versionLabel, 2, 0)

# Add layout to footer
$footerPanel.Controls.Add($footerLayout)

# Add footer to form
$form.Controls.Add($footerPanel)

# Add layouts to form
$form.Controls.Add($mainLayout)

# Add this line after all your controls are created but before showing the form
Load-SavedSettings

# Show the form
$form.ShowDialog()