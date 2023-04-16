#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "No version provided"
  echo "Usage: bootstrap_fedora.sh <version>"
  echo "For example: bootstrap_fedora.sh 37"
  exit 1
fi

echo "Making directories"
mkdir -p "/tmp/$1"

echo "Bootstrapping Fedora $1"
dnf -y --releasever="$1" --installroot=/tmp/"$1" groupinstall core

echo "Cleaning rootfs"
# Remove unneeded/temporary files to reduce the rootfs size
rm -rf /tmp/"$1"/boot/*
#rm -rf /tmp/"$1"/dev/*
rm -rf /tmp/"$1"/lost+found/*
rm -rf /tmp/"$1"/media/*
rm -rf /tmp/"$1"/mnt/*
#rm -rf /tmp/"$1"/proc/*
#rm -rf /tmp/"$1"/run/*
#rm -rf /tmp/"$1"/sys/*
rm -rf /tmp/"$1"/tmp/*
rm -rf /tmp/"$1"/var/tmp
#rm -rf /tmp/"$1"/var/cache

echo "Compressing rootfs"
cd "/tmp/$1"
tar -cv -I 'xz -9 -T0' -f ../fedora-rootfs-"$1".tar.xz ./

echo "Calculating sha256sum"
sha256sum ../fedora-rootfs-"$1".tar.xz >../fedora-rootfs-"$1".sha256sum
