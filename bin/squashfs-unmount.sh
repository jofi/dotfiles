#!/bin/bash

MOUNT_BASE="${HOME}/mnt/squashes"

# Unmount all SquashFS mount points
for MOUNT_POINT in "$MOUNT_BASE"/*; do
  sudo umount "$MOUNT_POINT"
  echo "Unmounted $MOUNT_POINT"
done
