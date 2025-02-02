#!/bin/sh

# Version 1.5.0

# Set default choices for the Argon version and DAC
choice=1        # Default to Argon V3 normal
use_dac="n"     # Default to no DAC

# Variables to track if changes were made
config_changed=0
eeprom_changed=0

# Function to check if a value is already in the config file
check_config() {
    grep -qF -- "$1" /flash/config.txt
}

# Function to apply configuration changes to config.txt
apply_config() {
    echo "$1" >> /flash/config.txt
    echo "Added $1 to /flash/config.txt."
    config_changed=1
}

# Function to check if a setting is already in the EEPROM config
check_eeprom_setting() {
    setting_name=$(echo "$1" | cut -d'=' -f1)
    setting_value=$(echo "$1" | cut -d'=' -f2)
    current_value=$(grep -w "^$setting_name" /tmp/current_eeprom.conf | cut -d'=' -f2)
    if [ "$current_value" = "$setting_value" ]; then
        return 0  # Setting is already set correctly
    else
        return 1  # Setting is missing or has a different value
    fi
}

# Ask the user which Argon version they are using
echo "Are you using Argon V3 normal, or Argon V3 with NVMe?"
echo "1) Argon V3 normal"
echo "2) Argon V3 with NVMe"
printf "Enter the number corresponding to your selection: "
read choice

# Confirm the selection
if [ "$choice" = "1" ]; then
    echo "You selected Argon V3 normal."
elif [ "$choice" = "2" ]; then
    echo "You selected Argon V3 with NVMe."
else
    echo "Invalid selection. Exiting."
    exit 1
fi

printf "Is this correct? (y/n) "
read confirm
if [ "$confirm" != "y" ]; then
    echo "Exiting. Please run the script again."
    exit 1
fi

# If the user selected Argon V3 with NVMe, ask for PCIe generation
if [ "$choice" = "2" ]; then
    # Ask user for NVMe PCIe generation choice
    echo "Select the PCIe generation for your NVMe drive:"
    echo "1) PCIe Gen 1"
    echo "2) PCIe Gen 2"
    echo "3) PCIe Gen 3"
    printf "Enter the number corresponding to your selection: "
    read pcie_choice

    # Apply PCIe Gen selection
    if [ "$pcie_choice" = "1" ]; then
        pcie_param_line1="dtparam=nvme"
        pcie_param_line2="dtparam=pciex1_1=gen1"
    elif [ "$pcie_choice" = "2" ]; then
        pcie_param_line1="dtparam=nvme"
        pcie_param_line2="dtparam=pciex1_1=gen2"
    elif [ "$pcie_choice" = "3" ]; then
        pcie_param_line1="dtparam=nvme"
        pcie_param_line2="dtparam=pciex1_1=gen3"
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
fi

# Ask if the user is using Argon V3 DAC
printf "Are you using Argon V3 DAC? (y/n) "
read use_dac

# Apply settings based on selection
mount -o remount,rw /flash

if [ "$choice" = "1" ]; then
    # Argon V3 normal
    # Apply config.txt settings
    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" \
                   "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            apply_config "$setting"
        else
            echo "config.txt value $setting already present. Skipping..."
        fi
    done
elif [ "$choice" = "2" ]; then
    # Argon V3 with NVMe
    # Apply NVMe and PCIe config
    for setting in "$pcie_param_line1" "$pcie_param_line2" \
                   "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" \
                   "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            apply_config "$setting"
        else
            echo "config.txt value $setting already present. Skipping..."
        fi
    done
fi

# DAC configuration
if [ "$use_dac" = "y" ]; then
    if ! check_config "dtoverlay=hifiberry-dacplus,slave"; then
        apply_config "dtoverlay=hifiberry-dacplus,slave"
    else
        echo "config.txt value dtoverlay=hifiberry-dacplus,slave already present. Skipping..."
    fi
fi

mount -o remount,ro /flash

# EEPROM updates
rpi-eeprom-config > /tmp/current_eeprom.conf
eeprom_updates=""

# Prepare EEPROM updates based on selection
if [ "$choice" = "1" ]; then
    # Argon V3 normal
    if ! check_eeprom_setting "PSU_MAX_CURRENT=5000"; then
        eeprom_updates="$eeprom_updates\nPSU_MAX_CURRENT=5000"
    else
        echo "EEPROM setting PSU_MAX_CURRENT=5000 already present. Skipping..."
    fi
elif [ "$choice" = "2" ]; then
    # Argon V3 with NVMe
    if ! check_eeprom_setting "BOOT_ORDER=0xf416"; then
        eeprom_updates="$eeprom_updates\nBOOT_ORDER=0xf416"
    else
        echo "EEPROM setting BOOT_ORDER=0xf416 already present. Skipping..."
    fi
    if ! check_eeprom_setting "PCIE_PROBE=1"; then
        eeprom_updates="$eeprom_updates\nPCIE_PROBE=1"
    else
        echo "EEPROM setting PCIE_PROBE=1 already present. Skipping..."
    fi
    if ! check_eeprom_setting "PSU_MAX_CURRENT=5000"; then
        eeprom_updates="$eeprom_updates\nPSU_MAX_CURRENT=5000"
    else
        echo "EEPROM setting PSU_MAX_CURRENT=5000 already present. Skipping..."
    fi
fi

# Apply EEPROM updates if necessary
if [ -n "$eeprom_updates" ]; then
    echo -e "$eeprom_updates" | grep -v '^$' > /tmp/boot.conf
    rpi-eeprom-config -a /tmp/boot.conf
    rm /tmp/boot.conf
    echo "EEPROM updated with new settings."
    eeprom_changed=1
else
    echo "No EEPROM updates necessary."
fi

rm /tmp/current_eeprom.conf

# Determine if a reboot is needed
if [ "$config_changed" -eq 1 ] || [ "$eeprom_changed" -eq 1 ]; then
    echo "A reboot is required for changes to take effect."
    printf "Do you want to reboot now? (y/n) "
    read reboot_confirm
    if [ "$reboot_confirm" = "y" ]; then
        echo "Rebooting now..."
        reboot
    else
        echo "Reboot skipped. Please remember to reboot your Raspberry Pi later."
    fi
else
    echo "No changes were made. Reboot is not required."
fi
