#!/bin/bash

source "$(dirname "$0")/sqfs-utils.sh"

# Check if any .sqfs files exist
if ! ls *.sqfs >/dev/null 2>&1; then
    echo "No .sqfs files found in current directory"
    exit 1
fi

for SQFS_FILE in *.sqfs; do
    MOUNT_POINT="$(pwd)/$(get_basename "$SQFS_FILE")"
    umount_sqfs "$MOUNT_POINT"
done
