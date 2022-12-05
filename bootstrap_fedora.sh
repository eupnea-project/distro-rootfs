#!/bin/bash

if [ -z "$1" ]; then
  echo "No version provided"
  echo "Usage: bootstrap_fedora.sh <version>"
  echo "Supported versions: 37, 38"
  exit 1
fi

echo "Making directories"
mkdir -p "/tmp/$1"

echo "Bootstrapping fedora"
dnf -y --releasever="$1" --installroot=/tmp/"$1" groupinstall core

echo "Compressing rootfs"
chdir "/tmp/$1"
tar -cv -I 'xz -9 -T0' -f ../fedora-rootfs-"$1".tar.xz ./
