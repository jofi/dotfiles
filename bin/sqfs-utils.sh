#!/bin/bash

# Default dataset location
export DATASETS="${DATASETS:-$HOME/Datasets}"

# Detect OS type
if [[ "$OSTYPE" == "darwin"* ]]; then
    MOUNT_CMD="squashfuse"
    UMOUNT_CMD="umount"
else
    MOUNT_CMD="sudo mount -t squashfs -o loop"
    UMOUNT_CMD="sudo umount"
fi

# Create mount point and ensure it exists
ensure_mount_point() {
    local mount_point="$1"
    mkdir -p "$mount_point"
}

# Get absolute path
get_absolute_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    fi
}

# Check if directory is a mount point
is_mount_point() {
    local mount_point="$1"
    local abs_path="$(get_absolute_path "$mount_point")"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Escape special characters in the path for grep
        local escaped_path="$(echo "$abs_path" | sed 's/[[\.*^$/]/\\&/g')"
        mount | grep -q " on $escaped_path "
    else
        mountpoint -q "$abs_path" 2>/dev/null
    fi
}

# Mount a single squashfs file
mount_sqfs() {
    local sqfs_file="$1"
    local mount_point="$2"
    local abs_sqfs="$(get_absolute_path "$sqfs_file")"
    local abs_mount="$(get_absolute_path "$mount_point")"
    
    if [[ ! -f "$abs_sqfs" ]]; then
        echo "Error: SquashFS file '$sqfs_file' not found"
        return 1
    fi
    
    ensure_mount_point "$abs_mount"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        $MOUNT_CMD "$abs_sqfs" "$abs_mount"
    else
        $MOUNT_CMD "$abs_sqfs" "$abs_mount"
    fi
    
    if [ $? -eq 0 ]; then
        echo "Mounted $sqfs_file to $mount_point"
    else
        echo "Failed to mount $sqfs_file"
        return 1
    fi
}

# Unmount a single mount point
umount_sqfs() {
    local mount_point="$1"
    local abs_mount="$(get_absolute_path "$mount_point")"
    
    if is_mount_point "$abs_mount"; then
        $UMOUNT_CMD "$abs_mount"
        if [ $? -eq 0 ]; then
            echo "Unmounted $mount_point"
        else
            echo "Failed to unmount $mount_point"
            return 1
        fi
    else
        echo "Not mounted: $mount_point"
    fi
}

# Get basename without extension
get_basename() {
    local filename="$1"
    basename "$filename" .sqfs
} 