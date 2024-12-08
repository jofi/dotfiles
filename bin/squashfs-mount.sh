#!/bin/bash

# Directory containing SquashFS files
MOUNT_ROOT=$1

# Directory containing SquashFS files
SQUASH_DIR=$2

# Mount point base directory
MOUNT_BASE="${HOME}/mnt/squashes/${MOUNT_ROOT}"

# Ensure the mount base directory exists
mkdir -p "$MOUNT_BASE"

# Iterate over each SquashFS file in the directory
for SQUASH_FILE in "$SQUASH_DIR"/*.sqfs; do
  # Get the base name of the file (without path and extension)
  BASE_NAME=$(basename "$SQUASH_FILE" .sqfs)

  # Create a directory for mounting
  MOUNT_POINT="$MOUNT_BASE/$BASE_NAME"
  mkdir -p "$MOUNT_POINT"

  # Mount the SquashFS file
  sudo mount -t squashfs -o loop "$SQUASH_FILE" "$MOUNT_POINT"

  echo "Mounted $SQUASH_FILE to $MOUNT_POINT"
done

