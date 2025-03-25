#!/bin/bash

source "$(dirname "$0")/sqfs-utils.sh"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <sqfs-file>"
    exit 1
fi

SQFS_FILE="$1"
MOUNT_POINT="$DATASETS/$(get_basename "$SQFS_FILE")"

mount_sqfs "$SQFS_FILE" "$MOUNT_POINT" 