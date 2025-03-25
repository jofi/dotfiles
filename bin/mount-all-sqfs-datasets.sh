#!/bin/bash

source "$(dirname "$0")/sqfs-utils.sh"

# Check if any .sqfs files exist
if ! ls *.sqfs >/dev/null 2>&1; then
    echo "No .sqfs files found in current directory"
    exit 1
fi

for SQFS_FILE in *.sqfs; do
    MOUNT_POINT="$DATASETS/$(get_basename "$SQFS_FILE")"
    mount_sqfs "$SQFS_FILE" "$MOUNT_POINT"
done 