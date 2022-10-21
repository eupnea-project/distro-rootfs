#!/usr/bin/env python3
import argparse

from functions import *


def process_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", dest="fedora_version", type=int, nargs=1, help="Set fedora version to boostrap")
    return parser.parse_args()


if __name__ == "__main__":
    set_verbose(True)
    args = process_args()
    fedora_version = args.fedora_version[0]

    print_status("Making directory")
    mkdir(f"/tmp/{fedora_version}")

    print_status(f"Bootstrapping Fedora version {fedora_version}")
    bash(f"dnf -y --releasever={fedora_version} --installroot=/tmp/{fedora_version} groupinstall core")

    print_status("Compressing rootfs")
    bash(f"tar -cv -I 'xz -9 -T0' -f /tmp/{fedora_version} ./fedora-rootfs-{fedora_version}.tar.xz")
