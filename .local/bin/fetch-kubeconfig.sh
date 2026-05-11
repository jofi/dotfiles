#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <hostname>"
  exit 1
fi

HOST="$1"
DEST="$(pwd)/kubeconfig.yml"

# Get the server's IP from the server itself
IP=$(ssh "afisadm@${HOST}" "hostname -I | awk '{print \$1}'")
if [ -z "$IP" ]; then
  echo "Error: could not determine IP of $HOST"
  exit 1
fi

echo "Fetching rke2.yaml from $HOST (IP: $IP)..."
ssh "afisadm@${HOST}" "sudo cat /etc/rancher/rke2/rke2.yaml" > "$DEST"

# Replace 127.0.0.1 with the server's IP
sed -i '' "s/127\.0\.0\.1/${IP}/g" "$DEST"

echo "Kubeconfig saved to $DEST"
