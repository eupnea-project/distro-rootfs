#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Distro not provided"
  echo "Usage: repack_rootfs.sh <distro>"
  echo "For example: extract_rootfs pop-os"
  echo "Supported distros: pop-os, mint-cinnamon"
  exit 1
fi

echo "Preparing system"
mkdir -p "/tmp/distro/cdrom"
mkdir "/tmp/distro/rootfs"
sudo modprobe isofs

echo "Downloading $1 iso"
if [ "$1" == "pop-os" ]; then
  # Get latest iso link
  distro_link=$(curl 'https://api.pop-os.org/builds/22.04/intel?arch=amd64' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:107.0) Gecko/20100101 Firefox/107.0' | jq -r ".url")
else
  distro_link="https://mirrors.layeronline.com/linuxmint/stable/21.1/linuxmint-21.1-cinnamon-64bit.iso"
fi

# Download image with latest link
curl -L "$distro_link" -o /tmp/distro/distro.iso

echo "Mounting $1 iso"
ISO_MNT=$(losetup -f --show /tmp/distro/distro.iso)
mount "$ISO_MNT" /tmp/distro/cdrom

echo "Extracting $1 squashfs"
unsquashfs -f -d /tmp/distro/rootfs /tmp/distro/cdrom/casper/filesystem.squashfs

echo "Cleaning rootfs"
# Remove unneeded/temporary files to reduce the rootfs size
rm -rf /tmp/distro/rootfs/boot/*
#rm -rf /tmp/distro/rootfs/dev/*
rm -rf /tmp/distro/rootfs/lost+found/*
rm -rf /tmp/distro/rootfs/media/*
rm -rf /tmp/distro/rootfs/mnt/*
#rm -rf /tmp/distro/rootfs/proc/*
#rm -rf /tmp/distro/rootfs/run/*
#rm -rf /tmp/distro/rootfs/sys/*
rm -rf /tmp/distro/rootfs/tmp/*
rm -rf /tmp/distro/rootfs/var/tmp/*
#rm -rf /tmp/distro/rootfs/var/cache

echo "Compressing rootfs"
cd "/tmp/distro/rootfs"
tar -cv -I 'xz -9 -T0' -f "../$1-rootfs-22.04.tar.xz" ./ # both distros use 22.04

echo "Calculating sha256sum"
# cd to where the rootfs is. Using ../ results in broken sha256sum checkfiles
cd ..
sha256sum "$1-rootfs-22.04.tar.xz" >"$1-rootfs-22.04.sha256" # both distros use 22.04
