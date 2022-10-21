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

    print_status("Making directory")
    mkdir(f"/tmp/{args.fedora_version}")

    print_status(f"Bootstrapping Fedora version {args.fedora_version}")
    bash(f"dnf -y --releasever={args.fedora_version} --installroot=/tmp/{args.fedora_version} groupinstall core")

    print_status("Compressing rootfs")
    bash(f"tar -cv -I 'xz -9 -T0' -f /tmp/{args.fedora_version} ./fedora-rootfs-{args.fedora_version}.tar.xz")
