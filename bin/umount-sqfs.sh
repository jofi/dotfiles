#!/bin/bash

source "$(dirname "$0")/sqfs-utils.sh"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <mount-point>"
    exit 1
fi

MOUNT_POINT="$1"
umount_sqfs "$MOUNT_POINT" 