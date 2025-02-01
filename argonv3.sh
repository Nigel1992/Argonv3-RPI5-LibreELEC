#!/bin/sh

# Version 1.3.0

# Set default choices for the Argon version and DAC
choice=1  # Default to Argon V3 normal
use_dac="n"  # Default to no DAC
reboot_confirm="n"

# Function to check if a value is already in the config file
check_config() {
    grep -qF -- "$1" /flash/config.txt
}

# Function to apply configuration changes to config.txt
apply_config() {
    echo "$1" >> /flash/config.txt
    echo -e "\e[1;32mAdded $1 to /flash/config.txt.\e[0m"
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
echo -e "\e[1;32mAre you using Argon V3 normal, or Argon V3 with NVMe?\e[0m"
echo "1) Argon V3 normal"
echo "2) Argon V3 with NVMe"
printf "Enter the number corresponding to your selection: "
read choice

# Confirm the selection
if [ "$choice" -eq 1 ]; then
    echo -e "\e[1;32mYou selected Argon V3 normal.\e[0m"
elif [ "$choice" -eq 2 ]; then
    echo -e "\e[1;32mYou selected Argon V3 with NVMe.\e[0m"
else
    echo -e "\e[1;31mInvalid selection. Exiting.\e[0m"
    exit 1
fi

printf "Is this correct? (y/n) "
read confirm
if [ "$confirm" != "y" ]; then
    echo -e "\e[1;31mExiting. Please run the script again.\e[0m"
    exit 1
fi

# If the user selected Argon V3 with NVMe, ask for PCIe generation
if [ "$choice" -eq 2 ]; then
    # Ask user for NVMe PCIe generation choice
    echo -e "\e[1;32mSelect the PCIe generation for your NVMe drive:\e[0m"
    echo "1) PCIe Gen 1"
    echo "2) PCIe Gen 2"
    echo "3) PCIe Gen 3"
    printf "Enter the number corresponding to your selection: "
    read pcie_choice

    # Apply PCIe Gen selection
    if [ "$pcie_choice" -eq 1 ]; then
        pcie_param_line1="dtparam=nvme"
        pcie_param_line2="dtparam=pciex1_1=gen1"
    elif [ "$pcie_choice" -eq 2 ]; then
        pcie_param_line1="dtparam=nvme"
        pcie_param_line2="dtparam=pciex1_1=gen2"
    elif [ "$pcie_choice" -eq 3 ]; then
        pcie_param_line1="dtparam=nvme"
        pcie_param_line2="dtparam=pciex1_1=gen3"
    else
        echo -e "\e[1;31mInvalid selection. Exiting.\e[0m"
        exit 1
    fi
fi

# Ask if the user is using Argon V3 DAC
printf "Are you using Argon V3 DAC? (y/n) "
read use_dac

# Apply settings based on selection
if [ "$choice" -eq 1 ]; then
    # Argon V3 normal
    mount -o remount,rw /flash
    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            apply_config "$setting"
        else
            echo -e "\e[1;33mconfig.txt value $setting already present. Skipping...\e[0m"
        fi
    done

    if [ "$use_dac" = "y" ]; then
        if ! check_config "dtoverlay=hifiberry-dacplus,slave"; then
            apply_config "dtoverlay=hifiberry-dacplus,slave"
        else
            echo -e "\e[1;33mconfig.txt value dtoverlay=hifiberry-dacplus,slave already present. Skipping...\e[0m"
        fi
    fi
    mount -o remount,ro /flash

    # Check current EEPROM settings
    rpi-eeprom-config > /tmp/current_eeprom.conf

    # Prepare EEPROM updates
    eeprom_updates=""
    if ! check_eeprom_setting "PSU_MAX_CURRENT=5000"; then
        eeprom_updates="$eeprom_updates\nPSU_MAX_CURRENT=5000"
    else
        echo -e "\e[1;33mEEPROM setting PSU_MAX_CURRENT=5000 already present. Skipping...\e[0m"
    fi

    # Apply EEPROM updates if necessary
    if [ -n "$eeprom_updates" ]; then
        echo -e "$eeprom_updates" | grep -v '^$' > /tmp/boot.conf
        rpi-eeprom-config -a /tmp/boot.conf
        rm /tmp/boot.conf
        echo -e "\e[1;32mEEPROM updated with new settings.\e[0m"
    else
        echo -e "\e[1;32mNo EEPROM updates necessary.\e[0m"
    fi
    rm /tmp/current_eeprom.conf

elif [ "$choice" -eq 2 ]; then
    # Argon V3 with NVMe
    mount -o remount,rw /flash

    # Add PCIe Gen selection and NVMe config
    for param in "$pcie_param_line1" "$pcie_param_line2"; do
        if ! check_config "$param"; then
            apply_config "$param"
        else
            echo -e "\e[1;33mconfig.txt value $param already present. Skipping...\e[0m"
        fi
    done

    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            apply_config "$setting"
        else
            echo -e "\e[1;33mconfig.txt value $setting already present. Skipping...\e[0m"
        fi
    done

    if [ "$use_dac" = "y" ]; then
        if ! check_config "dtoverlay=hifiberry-dacplus,slave"; then
            apply_config "dtoverlay=hifiberry-dacplus,slave"
        else
            echo -e "\e[1;33mconfig.txt value dtoverlay=hifiberry-dacplus,slave already present. Skipping...\e[0m"
        fi
    fi

    mount -o remount,ro /flash

    # Check current EEPROM settings
    rpi-eeprom-config > /tmp/current_eeprom.conf

    # Prepare EEPROM updates
    eeprom_updates=""
    if ! check_eeprom_setting "BOOT_ORDER=0xf416"; then
        eeprom_updates="$eeprom_updates\nBOOT_ORDER=0xf416"
    else
        echo -e "\e[1;33mEEPROM setting BOOT_ORDER=0xf416 already present. Skipping...\e[0m"
    fi

    if ! check_eeprom_setting "PCIE_PROBE=1"; then
        eeprom_updates="$eeprom_updates\nPCIE_PROBE=1"
    else
        echo -e "\e[1;33mEEPROM setting PCIE_PROBE=1 already present. Skipping...\e[0m"
    fi

    if ! check_eeprom_setting "PSU_MAX_CURRENT=5000"; then
        eeprom_updates="$eeprom_updates\nPSU_MAX_CURRENT=5000"
    else
        echo -e "\e[1;33mEEPROM setting PSU_MAX_CURRENT=5000 already present. Skipping...\e[0m"
    fi

    # Apply EEPROM updates if necessary
    if [ -n "$eeprom_updates" ]; then
        echo -e "$eeprom_updates" | grep -v '^$' > /tmp/boot.conf
        rpi-eeprom-config -a /tmp/boot.conf
        rm /tmp/boot.conf
        echo -e "\e[1;32mEEPROM updated with new settings.\e[0m"
    else
        echo -e "\e[1;32mNo EEPROM updates necessary.\e[0m"
    fi
    rm /tmp/current_eeprom.conf
fi

# Ask if the user wants to reboot
echo -e "\e[1;32mA reboot is only required if config.txt and/or EEPROM has been updated.\e[0m"
printf "Do you want to reboot now? (y/n) "
read reboot_confirm
if [ "$reboot_confirm" = "y" ]; then
    echo "Rebooting now..."
    reboot
else
    echo "Reboot skipped. Please remember to reboot your Raspberry Pi later if needed."
fi
