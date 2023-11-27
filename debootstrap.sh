#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "No distro provided"
  echo "Usage: debootstrap.sh [debian | ubuntu] <version> <codename>"
  echo "For example: debootstrap.sh ubuntu 22.04 jammy"
  echo "For example: debootstrap.sh debian 12 bookworm"
  exit 1
fi

if [ -z "$2" ]; then
  echo "No version provided"
  echo "Usage: debootstrap.sh [debian | ubuntu] <codename>"
  echo "For example: debootstrap.sh ubuntu 22.04 jammy"
  echo "For example: debootstrap.sh debian 12 bookworm"
  exit 1
fi

if [ -z "$3" ]; then
  echo "No codename provided"
  echo "Usage: debootstrap.sh [debian | ubuntu] <version> <codename>"
  echo "For example: debootstrap.sh ubuntu 22.04 jammy"
  echo "For example: debootstrap.sh debian 12 bookworm"
  exit 1
fi

echo "Making directories"
mkdir -p "/tmp/$2"

echo "Bootstrapping $1 $2 $3"
if [ "$1" == "ubuntu" ]; then
  debootstrap --components=main,restricted,universe,multiverse "$3" /tmp/"$2" http://archive.ubuntu.com/ubuntu
elif [ "$1" == "debian" ]; then
  debootstrap "$3" /tmp/"$2" http://deb.debian.org/debian/
else
  echo "Unsupported distro"
  echo "Only ubuntu or debian is allowed"
  echo "Usage: debootstrap.sh [debian | ubuntu] <version> <codename>"
  echo "For example: debootstrap.sh ubuntu 22.04 jammy"
  echo "For example: debootstrap.sh debian 12 bookworm"
  exit 1
fi

echo "Cleaning rootfs"
# Remove unneeded/temporary files to reduce the rootfs size
rm -rf /tmp/"$2"/boot/*
#rm -rf /tmp/"$2"/dev/*
rm -rf /tmp/"$2"/lost+found/*
rm -rf /tmp/"$2"/media/*
rm -rf /tmp/"$2"/mnt/*
#rm -rf /tmp/"$2"/proc/*
#rm -rf /tmp/"$2"/run/*
#rm -rf /tmp/"$2"/sys/*
rm -rf /tmp/"$2"/tmp/*
rm -rf /tmp/"$2"/var/tmp
#rm -rf /tmp/"$2"/var/cache

echo "Compressing rootfs"
cd "/tmp/$2"
tar -cv -I 'xz -9 -T0' -f ../$1-rootfs-"$2".tar.xz ./

echo "Calculating sha256sum"
# cd to where the rootfs is. Using ../ results in broken sha256sum checkfiles
cd ..
sha256sum $1-rootfs-"$2".tar.xz >$1-rootfs-"$2".sha256
