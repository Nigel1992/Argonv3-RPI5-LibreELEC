#!/bin/sh

# Constants
CONFIG_FILE="/flash/config.txt"
EEPROM_TMP="/tmp/current_eeprom.conf"
VERSION="1.1.0 (03/26/2024)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# SSH connection details
IP_ADDRESS=""
USERNAME=""
PASSWORD=""
SSH_METHOD=""

# Helper functions
print_colored() {
    echo -e "${1}${2}${RESET}"
}

print_header() {
    clear
    print_colored "$BLUE" "╔════════════════════════════════════════╗"
    print_colored "$BLUE" "║       Argon V3 - LibreELEC Setup       ║"
    print_colored "$BLUE" "║            Version $VERSION        ║"
    print_colored "$BLUE" "╚════════════════════════════════════════╝"
    echo
}

detect_ssh_method() {
    if command -v sshpass >/dev/null 2>&1; then
        SSH_METHOD="sshpass"
    elif command -v ssh-copy-id >/dev/null 2>&1; then
        SSH_METHOD="ssh-copy-id"
    else
        SSH_METHOD="manual"
    fi
}

setup_ssh_connection() {
    case $SSH_METHOD in
        "sshpass")
            if ! sshpass -p "$PASSWORD" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USERNAME@$IP_ADDRESS" "exit" >/dev/null 2>&1; then
                return 1
            fi
            ;;
        "ssh-copy-id")
            print_colored "$YELLOW" "Attempting to set up SSH key authentication..."
            if ! ssh-copy-id "$USERNAME@$IP_ADDRESS" >/dev/null 2>&1; then
                return 1
            fi
            ;;
        "manual")
            print_colored "$YELLOW" "Testing basic SSH connection..."
            if ! ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no "$USERNAME@$IP_ADDRESS" "exit" >/dev/null 2>&1; then
                return 1
            fi
            ;;
    esac
    return 0
}

remote_command() {
    case $SSH_METHOD in
        "sshpass")
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$IP_ADDRESS" "$1"
            ;;
        *)
            ssh -o StrictHostKeyChecking=no "$USERNAME@$IP_ADDRESS" "$1"
            ;;
    esac
}

print_connection_help() {
    print_colored "$RED" "Failed to connect to $IP_ADDRESS. Please check:"
    print_colored "$YELLOW" "1. SSH is enabled in LibreELEC (Settings -> Services -> SSH)"
    print_colored "$YELLOW" "2. Your IP address is correct"
    print_colored "$YELLOW" "3. LibreELEC is running and on the network"
    echo
    print_colored "$GREEN" "To enable SSH in LibreELEC:"
    print_colored "$YELLOW" "- Using the UI: Settings -> Services -> SSH -> Enable"
    print_colored "$YELLOW" "- Using the web interface: http://$IP_ADDRESS -> Services -> Enable SSH"
    echo
    case $SSH_METHOD in
        "manual")
            print_colored "$YELLOW" "Note: Installing sshpass might make the connection process easier:"
            print_colored "$YELLOW" "- Windows/Git Bash: Download from https://sourceforge.net/projects/sshpass/"
            print_colored "$YELLOW" "- Linux: sudo apt-get install sshpass (or your distro's equivalent)"
            print_colored "$YELLOW" "- macOS: brew install esolitos/ipa/sshpass"
            ;;
    esac
}

get_credentials() {
    print_colored "$GREEN" "Please enter your LibreELEC connection details:"
    echo
    echo -n "IP Address: "
    read -r IP_ADDRESS
    
    # Validate IP address format
    if ! echo "$IP_ADDRESS" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' >/dev/null; then
        print_colored "$RED" "Invalid IP address format. Please try again."
        return 1
    fi
    
    echo -n "Username (default: root): "
    read -r USERNAME
    USERNAME=${USERNAME:-root}
    
    echo -n "Password (default: libreelec): "
    read -r -s PASSWORD
    PASSWORD=${PASSWORD:-libreelec}
    echo
    
    # Detect best SSH method
    detect_ssh_method
    print_colored "$YELLOW" "Testing SSH connection..."
    
    if ! setup_ssh_connection; then
        print_connection_help
        return 1
    fi
    
    print_colored "$GREEN" "Successfully connected to LibreELEC!"
    return 0
}

confirm_choice() {
    printf "Is this correct? (y/n) "
    read -r confirm
    [ "$confirm" = "y" ]
}

check_config() {
    remote_command "grep -qF -- \"$1\" $CONFIG_FILE"
}

apply_config() {
    remote_command "echo \"$1\" >> $CONFIG_FILE"
    print_colored "$GREEN" "Added $1 to $CONFIG_FILE"
    config_changed=1
}

check_eeprom_setting() {
    setting_name=$(echo "$1" | cut -d'=' -f1)
    setting_value=$(echo "$1" | cut -d'=' -f2)
    current_value=$(remote_command "grep -w \"^$setting_name\" $EEPROM_TMP" | cut -d'=' -f2)
    [ "$current_value" = "$setting_value" ]
}

# Main script
print_header

# Get SSH credentials first
while ! get_credentials; do
    echo
    echo -n "Would you like to try again? (y/n): "
    read -r retry
    [ "$retry" != "y" ] && exit 1
    echo
done

# Initialize variables
config_changed=0
eeprom_changed=0
eeprom_updates=""

# Get Argon version
print_colored "$GREEN" "Are you using Argon V3 normal, or Argon V3 with NVMe?"
echo "1) Argon V3 normal"
echo "2) Argon V3 with NVMe"
printf "Enter your selection (1/2): "
read -r choice

case "$choice" in
    1) print_colored "$GREEN" "You selected Argon V3 normal." ;;
    2) print_colored "$GREEN" "You selected Argon V3 with NVMe." ;;
    *) print_colored "$RED" "Invalid selection. Exiting."; exit 1 ;;
esac

confirm_choice || { print_colored "$RED" "Exiting. Please run the script again."; exit 1; }

# NVMe PCIe configuration
if [ "$choice" = "2" ]; then
    print_colored "$GREEN" "Select the PCIe generation for your NVMe drive:"
    echo "1) PCIe Gen 1"
    echo "2) PCIe Gen 2"
    echo "3) PCIe Gen 3"
    printf "Enter your selection (1/2/3): "
    read -r pcie_choice

    case "$pcie_choice" in
        1) pcie_gen="gen1" ;;
        2) pcie_gen="gen2" ;;
        3) pcie_gen="gen3" ;;
        *) print_colored "$RED" "Invalid selection. Exiting."; exit 1 ;;
    esac
    
    pcie_params="dtparam=nvme\ndtparam=pciex1_1=$pcie_gen"
fi

# DAC configuration
echo -e -n "${GREEN}Are you using Argon V3 DAC (y/n) ?${RESET} "
read -r use_dac

# Apply configurations
remote_command "mount -o remount,rw /flash"

# Common config settings
config_settings="dtoverlay=gpio-ir,gpio_pin=23
dtparam=i2c=on
enable_uart=1
usb_max_current_enable=1"

# Add NVMe settings if applicable
[ "$choice" = "2" ] && config_settings="$config_settings\n$pcie_params"

# Add DAC settings if applicable
[ "$use_dac" = "y" ] && config_settings="$config_settings\ndtoverlay=hifiberry-dacplus,slave"

# Apply config settings
echo -e "$config_settings" | while IFS= read -r setting; do
    [ -n "$setting" ] || continue
    if ! check_config "$setting"; then
        apply_config "$setting"
    else
        print_colored "$YELLOW" "config.txt value $setting already present. Skipping..."
    fi
done

remote_command "mount -o remount,ro /flash"

# EEPROM configuration
remote_command "rpi-eeprom-config > $EEPROM_TMP"

# Set EEPROM updates based on version
if [ "$choice" = "1" ]; then
    [ "$(check_eeprom_setting 'PSU_MAX_CURRENT=5000')" ] || eeprom_updates="PSU_MAX_CURRENT=5000"
else
    for setting in "BOOT_ORDER=0xf416" "PCIE_PROBE=1" "PSU_MAX_CURRENT=5000"; do
        [ "$(check_eeprom_setting "$setting")" ] || eeprom_updates="$eeprom_updates\n$setting"
    done
fi

# Apply EEPROM updates if needed
if [ -n "$eeprom_updates" ]; then
    remote_command "echo -e \"$eeprom_updates\" | grep -v '^$' > /tmp/boot.conf"
    remote_command "rpi-eeprom-config -a /tmp/boot.conf"
    remote_command "rm /tmp/boot.conf"
    print_colored "$GREEN" "EEPROM updated with new settings."
    eeprom_changed=1
else
    print_colored "$GREEN" "No EEPROM updates necessary."
fi

remote_command "rm $EEPROM_TMP"

# Handle reboot
if [ "$config_changed" -eq 1 ] || [ "$eeprom_changed" -eq 1 ]; then
    print_colored "$GREEN" "A reboot is required for changes to take effect."
    printf "Do you want to reboot now? (y/n) "
    read -r reboot_confirm
    if [ "$reboot_confirm" = "y" ]; then
        echo "Rebooting now..."
        remote_command "reboot"
    else
        echo "Reboot skipped. Please remember to reboot your Raspberry Pi later."
    fi
else
    echo "No reboot needed."
fi
