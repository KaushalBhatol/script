#!/bin/bash
set -euo pipefail

# create_swap.sh — create and enable a swap file of size $1 GiB

# 1. Must run as root
if (( EUID != 0 )); then
  echo "Error: this script must be run as root." >&2
  exit 1
fi

# 2. Validate argument
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <size-in-GiB>" >&2
  exit 1
fi

SIZE_GB=$1
if ! [[ $SIZE_GB =~ ^[0-9]+$ ]] || (( SIZE_GB < 1 )); then
  echo "Error: size must be a positive integer (GiB)." >&2
  exit 1
fi

SWAPFILE="/swapfile"

# 3. Create the swap file
echo "Allocating ${SIZE_GB}GiB swap file at ${SWAPFILE}..."
fallocate -l "${SIZE_GB}G" "$SWAPFILE"

# 4. Secure it
echo "Setting permissions to 600..."
chmod 600 "$SWAPFILE"

# 5. Make and enable swap
echo "Initializing swap area..."
mkswap "$SWAPFILE"
echo "Enabling swap..."
swapon "$SWAPFILE"

# 6. Persist across reboots
echo "Adding to /etc/fstab (if not already present)..."
if ! grep -q "^${SWAPFILE} " /etc/fstab; then
  echo "${SWAPFILE} none swap sw 0 0" | tee -a /etc/fstab
else
  echo "→ Entry for ${SWAPFILE} already exists in /etc/fstab"
fi

# 7. Summary
echo ""
echo "Swap of ${SIZE_GB}GiB is now active:"
swapon --show | grep "$SWAPFILE"
echo ""
echo "Done!"
