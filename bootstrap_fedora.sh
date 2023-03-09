#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "No version provided"
  echo "Usage: bootstrap_fedora.sh <version>"
  echo "Supported versions: 37, 38"
  exit 1
fi

echo "Making directories"
mkdir -p "/tmp/$1"

echo "Bootstrapping Fedora $1"
dnf -y --releasever="$1" --installroot=/tmp/"$1" groupinstall core

echo "Updating all packages inside rootfs"
chroot /tmp/"$1" /bin/bash -c "dnf install -y --releasever=$1 fedora-release" # Install the correct release package
chroot /tmp/"$1" /bin/bash -c "dnf update -y"

echo "Cleaning rootfs"
# Remove unneeded/temporary files to reduce the rootfs size
rm -rf /tmp/"$1"/boot/*
rm -rf /tmp/"$1"/dev/*
rm -rf /tmp/"$1"/lost+found/*
rm -rf /tmp/"$1"/media/*
rm -rf /tmp/"$1"/mnt/*
rm -rf /tmp/"$1"/proc/*
rm -rf /tmp/"$1"/run/*
rm -rf /tmp/"$1"/sys/*
rm -rf /tmp/"$1"/tmp/*
rm -rf /tmp/"$1"/var/tmp
rm -rf /tmp/"$1"/var/cache

echo "Compressing rootfs"
cd "/tmp/$1"
tar -cv -I 'xz -9 -T0' -f ../fedora-rootfs-"$1".tar.xz ./

echo "Calculating sha256sum"
sha256sum ../fedora-rootfs-"$1".tar.xz > ../fedora-rootfs-"$1".sha256sum
