#!/bin/bash

# Set default choices for the Argon version and DAC
choice=1  # Default to Argon V3 normal
use_dac="n"  # Default to no DAC


# Function to check if a value is already in the config file
check_config() {
    grep -q "$1" /flash/config.txt
}

# Function to apply configuration changes to config.txt
apply_config() {
    echo -e "$1" >> /flash/config.txt
    echo -e "\e[1;32mAdded $1 to /flash/config.txt.\e[0m"
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

# Ask user for NVMe PCIe generation choice
echo -e "\e[1;32mSelect the PCIe generation for your NVMe drive:\e[0m"
echo "1) PCIe Gen 1"
echo "2) PCIe Gen 2"
echo "3) PCIe Gen 3"
read -p "Enter the number corresponding to your selection: " pcie_choice

# Apply PCIe Gen selection
case "$pcie_choice" in
    1)
        pcie_param="dtparam=nvme\ndtparam=pciex1_1=gen1"
        ;;
    2)
        pcie_param="dtparam=nvme\ndtparam=pciex1_1=gen2"
        ;;
    3)
        pcie_param="dtparam=nvme\ndtparam=pciex1_1=gen3"
        ;;
    *)
        echo -e "\e[1;31mInvalid selection. Exiting.\e[0m"
        exit 1
        ;;
esac

# Ask if the user is using Argon V3 DAC
read -p "Are you using Argon V3 DAC? (y/n) " use_dac

# Apply settings based on selection
if [ "$choice" -eq 1 ]; then
    # Argon V3 normal
    if ! check_config 'PSU_MAX_CURRENT=5000'; then
        apply_config 'PSU_MAX_CURRENT=5000'
    fi

    mount -o remount,rw /flash
    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            apply_config "$setting"
        else
            echo -e "\e[1;33m$config.txt value $setting already present. Skipping...\e[0m"
        fi
    done

    if [ "$use_dac" == "y" ]; then
        if ! check_config 'dtoverlay=hifiberry-dacplus,slave'; then
            apply_config 'dtoverlay=hifiberry-dacplus,slave'
        else
            echo -e "\e[1;33mconfig.txt value dtoverlay=hifiberry-dacplus,slave already present. Skipping...\e[0m"
        fi
    fi
    mount -o remount,ro /flash

elif [ "$choice" -eq 2 ]; then
    # Argon V3 with NVMe
    mount -o remount,rw /flash

    # Add PCIe Gen selection and NVMe config
    if ! check_config "$pcie_param"; then
        apply_config "$pcie_param"
    else
        echo -e "\e[1;33mconfig.txt value $pcie_param already present. Skipping...\e[0m"
    fi

    for setting in "dtoverlay=gpio-ir,gpio_pin=23" "dtparam=i2c=on" "enable_uart=1" "usb_max_current_enable=1"; do
        if ! check_config "$setting"; then
            apply_config "$setting"
        else
            echo -e "\e[1;33m$config.txt value $setting already present. Skipping...\e[0m"
        fi
    done

    if [ "$use_dac" == "y" ]; then
        if ! check_config 'dtoverlay=hifiberry-dacplus,slave'; then
            apply_config 'dtoverlay=hifiberry-dacplus,slave'
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
