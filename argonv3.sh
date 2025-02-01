#!/bin/bash

# Function to check if a value is already in the config file
check_config() {
    grep -q "$1" /flash/config.txt
}

# Function to apply EEPROM configuration
apply_eeprom_config() {
    echo -e "$1" | tee /tmp/boot.conf && rpi-eeprom-config -a /tmp/boot.conf && rm /tmp/boot.conf
}

# Ask the user which Argon version they are using
echo -e "\e[1;32mAre you using Argon V3 normal, or Argon V3 with NVMe?\e[0m"
echo "1) Argon V3 normal"
echo "2) Argon V3 with NVMe"
read -p "Enter the number corresponding to your selection: " choice

# Confirm the selection
if [ "$choice" -eq 1 ]; then
    echo -e "\e[1;32mYou selected Argon V3 normal.\e[0m"
elif [ "$choice" -eq 2 ]; then
    echo -e "\e[1;32mYou selected Argon V3 with NVMe.\e[0m"
else
    echo -e "\e[1;31mInvalid selection. Exiting.\e[0m"
    exit 1
fi

read -p "Is this correct? (y/n) " confirm
if [ "$confirm" != "y" ]; then
    echo -e "\e[1;31mExiting. Please run the script again.\e[0m"
    exit 1
fi

# Ask if the user is using Argon V3 DAC
read -p "Are you using Argon V3 DAC? (y/n) " use_dac

# Apply settings based on selection
if [ "$choice" -eq 1 ]; then
    # Argon V3 normal
    if ! rpi-eeprom-config | grep -q 'PSU_MAX_CURRENT=5000'; then
        apply_eeprom_config 'PSU_MAX_CURRENT=5000'
        echo -e "\e[1;32mEEPROM value PSU_MAX_CURRENT=5000 added.\e[0m"
    else
        echo -e "\e[1;33mEEPROM value PSU_MAX_CURRENT=5000 already present. Skipping...\e[0m"
    fi

    mount -o remount,rw /flash
    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            echo -e "$setting" >> /flash/config.txt
            echo -e "\e[1;32mconfig.txt value $setting added.\e[0m"
        else
            echo -e "\e[1;33mconfig.txt value $setting already present. Skipping...\e[0m"
        fi
    done

    if [ "$use_dac" == "y" ]; then
        if ! check_config 'dtoverlay=hifiberry-dacplus,slave'; then
            echo -e 'dtoverlay=hifiberry-dacplus,slave' >> /flash/config.txt
            echo -e "\e[1;32mconfig.txt value dtoverlay=hifiberry-dacplus,slave added.\e[0m"
        else
            echo -e "\e[1;33mconfig.txt value dtoverlay=hifiberry-dacplus,slave already present. Skipping...\e[0m"
        fi
    fi
    mount -o remount,ro /flash

elif [ "$choice" -eq 2 ]; then
    # Argon V3 with NVMe
    if ! rpi-eeprom-config | grep -q 'BOOT_ORDER=0xf416'; then
        apply_eeprom_config 'BOOT_ORDER=0xf416\nPCIE_PROBE=1\nPSU_MAX_CURRENT=5000'
        echo -e "\e[1;32mEEPROM values BOOT_ORDER=0xf416, PCIE_PROBE=1, and PSU_MAX_CURRENT=5000 added.\e[0m"
    else
        echo -e "\e[1;33mEEPROM values BOOT_ORDER=0xf416, PCIE_PROBE=1, and PSU_MAX_CURRENT=5000 already present. Skipping...\e[0m"
    fi

    mount -o remount,rw /flash
    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            echo -e "$setting" >> /flash/config.txt
            echo -e "\e[1;32mconfig.txt value $setting added.\e[0m"
        else
            echo -e "\e[1;33mconfig.txt value $setting already present. Skipping...\e[0m"
        fi
    done

    if [ "$use_dac" == "y" ]; then
        if ! check_config 'dtoverlay=hifiberry-dacplus,slave'; then
            echo -e 'dtoverlay=hifiberry-dacplus,slave' >> /flash/config.txt
            echo -e "\e[1;32mconfig.txt value dtoverlay=hifiberry-dacplus,slave added.\e[0m"
        else
            echo -e "\e[1;33mconfig.txt value dtoverlay=hifiberry-dacplus,slave already present. Skipping...\e[0m"
        fi
    fi
    mount -o remount,ro /flash
fi
# Ask if the user wants to reboot
echo -e "\e[1;32mA reboot is required for changes to take effect.\e[0m"
read -p "Do you want to reboot now? (y/n) " reboot_confirm
if [ "$reboot_confirm" == "y" ]; then
    echo "Rebooting now..."
    reboot
else
    echo "Reboot skipped. Please remember to reboot your Raspberry Pi later."
fi
