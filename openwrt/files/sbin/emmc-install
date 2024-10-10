#!/bin/bash

# Author: sbwml <admin@cooluc.com>
# This script helps the automation Flashing the eMMC in a NanoPi R5S.

# check
commands=("bash" "parted" "awk" "sed" "grep" "zcat" "dd" "fdisk")
for cmd in "${commands[@]}"; do
    if ! which "$cmd" >/dev/null 2>&1; then
        echo "Command $cmd does not exist."
        exit 1
    fi
done

if [ -z "$1" ]; then
    echo "Firmware file does not specified."
    echo "Usage: $0 <firmware file .tar.gz | .img>"
    exit 0
fi

echo " "
echo "Starting eMMC Flashing ..."

# eMMC device
echo " "
echo "eMMC info"
emmc_device=$(parted -l 2>/dev/null | grep -A 1 -E 'Model: MMC .*sd/mmc' | tail -n1 | awk '{print $2}' | sed 's/://g')
emmc_size=$(parted -l 2>/dev/null | grep -A 1 -E 'Model: MMC .*sd/mmc' | tail -n1 | awk '{print $3}')
emmc_device_name=$(echo $emmc_device | awk -F/ '{print $3}')
emmc_partition=$(fdisk -l 2>/dev/null | grep "$emmc_device_name"p | wc -l)
if [ "$emmc_partition" -eq 3 ]; then
    emmc_p3_start=$(fdisk -l 2>/dev/null | grep "$emmc_device_name"p3 | awk '{print $2}')
    emmc_p3_end=$(fdisk -l 2>/dev/null | grep "$emmc_device_name"p3 | awk '{print $3}')
fi

if [ -n "$emmc_device" ]; then
    echo "Device: $emmc_device"
    echo "Size: $emmc_size"
else
    echo "No available eMMC storage device found."
    exit 1
fi

echo " "
read -p "This script will erase your eMMC. Continue [y/n]? " -n 1 -r
echo " "
if [[ $REPLY =~ ^[Nn]$ ]]; then
   echo "Exiting script."
   exit 1
fi

firmware_file="$1"
if [ -e "$firmware_file" ]; then
    extension="${firmware_file##*.}"
    if [ "$extension" = "gz" ]; then
        echo " "
        echo "Gzip decompression $firmware_file ..."
        zcat "$firmware_file" > /var/firmware.img
        firmware_file_path="/var/firmware.img"
    elif [ "$extension" = "img" ]; then
        firmware_file_path="$firmware_file"
    else
        echo "Only supports firmware files with .gz or .img suffixes."
        exit 1
    fi
else
    echo "The firmware file does not exist."
    exit 1
fi

echo "Flashing ..."
dd if="$firmware_file_path" of="$emmc_device" bs=1M conv=fsync
if [ "$emmc_partition" -eq 3 ]; then
    echo "Recreate eMMC storage partition 3 ..."
    fdisk "$emmc_device" << EOM > /dev/null 2>&1
n
p

$emmc_p3_start
$emmc_p3_end

wq
EOM
fi
echo " "
echo "Done!"
echo "Please remove the TF card and Power off and restart device."
echo " "
