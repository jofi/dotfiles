#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") [user@]<hostname>  (default user: afisadm)"
  exit 1
fi

if [[ "$1" == *@* ]]; then
  TARGET="$1"
  HOST="${1##*@}"
else
  TARGET="afisadm@$1"
  HOST="$1"
fi
DEST="$(pwd)/kubeconfig.yml"

# Get the server's IP from the server itself
IP=$(ssh "$TARGET" "hostname -I | awk '{print \$1}'")
if [ -z "$IP" ]; then
  echo "Error: could not determine IP of $HOST"
  exit 1
fi

echo "Fetching rke2.yaml from $HOST (IP: $IP)..."
ssh "$TARGET" "sudo cat /etc/rancher/rke2/rke2.yaml" > "$DEST"

# Replace 127.0.0.1 with the server's IP
sed -i '' "s/127\.0\.0\.1/${IP}/g" "$DEST"

echo "Kubeconfig saved to $DEST"
