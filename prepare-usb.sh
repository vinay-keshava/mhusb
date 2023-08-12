#!/bin/bash 

usb=$1
size=$2
part=`echo $usb`1
rsync="rsync --delete -rvtDW --progress --modify-window=1"
ventoy="./ventoy/Ventoy2Disk.sh"

if [ -z $usb -o -z $size ]
then
  echo "Usage: sudo ./prepare-usb.sh <device> <size>"
  exit 1
fi

if [ $size -eq 16 -o $size -eq 32 ]
then
  echo "Working with $size GB disk..."
else
  echo "Usage: sudo ./prepare-usb.sh <device> <size>"
  echo "       <size> should be 16 or 32"
  exit 1
fi

if [ $UID -gt 0 ]
then
  echo "Please run as root."
  echo "Usage: sudo ./prepare-usb.sh <device>"
  exit 1
fi

OS_FOR_16GB="
  alpine-standard-3.16.2-x86_64.iso*
  debian-11.5.0-amd64-netinst.iso*
  Fedora-Workstation-Live-x86_64-36-1.5.iso*
  guix-system-install-1.3.0.x86_64-linux.iso*
  manjaro-kde-21.3.7-220816-linux515.iso*
  netboot.xyz.iso*
  openwrt-22.03.2-x86-64-generic-ext4-combined.img*
  proxmox-ve_7.2-1.iso*
  systemrescue-9.05-amd64.iso*
  tails-amd64-5.6.img*
  trisquel-mini_10.0.1_amd64.iso*
  ubuntu-22.04.1-desktop-amd64.iso*
  zdebian-firmware-11.5.0-amd64-netinst.iso*
"

OS_FOR_32GB_DEBIAN="
  DEBIAN/debian-12.1.0-amd64-netinst.iso*
  DEBIAN/debian-12.1.0-amd64-DVD-1.iso* 
  DEBIAN/debian-live-12.1.0-amd64-kde.iso*
  DEBIAN/debian-live-12.1.0-amd64-gnome.iso*
"
OS_FOR_32GB_OTHER="
  OTHER/Fedora-Workstation-Live-x86_64-38-1.6.iso*
  OTHER/manjaro-kde-22.1.3-230529-linux61.iso*
  OTHER/netboot.xyz.img*
  OTHER/netboot.xyz.iso*
  OTHER/proxmox-ve_8.0-2.iso*
  OTHER/systemrescue-9.05-amd64.iso*
  OTHER/tails-amd64-5.16.img*
  OTHER/trisquel_11.0_amd64.iso*
  OTHER/ubuntu-22.04.1-desktop-amd64.iso*
  OTHER/Qubes-R4.1.1-x86_64.iso*
 "

RPi="
  2022-09-22-raspios-bullseye-arm64-lite.img.xz
  2022-09-22-raspios-bullseye-armhf-lite.img.xz
"

TOOLS="
  balenaEtcher-1.7.9-x64.AppImage
  balenaEtcher-Setup-1.7.9.exe
  ungoogled-chromium_107.0.5304.68-1.1.AppImage
"

## Install Ventoy
if [ $size -eq 16 ]
then
  $ventoy -i /dev/$usb -L MH-USB -I -g
  sleep 20
  OS=$OS_FOR_16GB
else
  $ventoy -i /dev/$usb -L MH-USB -I -g
  sleep 20
  OS_DEB=$OS_FOR_32GB_DEBIAN
  OS_OTH=$OS_FOR_32GB_OTHER 
fi

## Copy ISOs
mkdir -p /mnt/mhusb/
mount /dev/$part /mnt/mhusb
mkdir -p /mnt/mhusb/OS/DEBIAN
mkdir -p /mnt/mhusb/OS/OTHER
mkdir -p /mnt/mhusb/Tools

cd MH-USB/OS/
time $rsync $OS_DEB /mnt/mhusb/OS/DEBIAN
time $rsync $OS_OTH /mnt/mhusb/OS/OTHER

cd ../Tools/
time $rsync $TOOLS /mnt/mhusb/Tools/

cd ../
time $rsync /home/vinay/mh/usb/MH-USB/ventoy /mnt/mhusb

#if [ $size -eq 32 ]
#then
#  cd RPi/
#  mkdir -p /mnt/mhusb/RPi/
#  $rsync $RPi /mnt/mhusb/RPi/
#fi

echo "Done."

