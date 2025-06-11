#!/bin/bash
set -euo pipefail

# change_ssh_port.sh — change SSHD listen port to $1

# 1. Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "Error: this script must be run as root." >&2
  exit 1
fi

# 2. Validate argument
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new-port-number>" >&2
  exit 1
fi

NEW_PORT=$1
if ! [[ $NEW_PORT =~ ^[0-9]+$ ]] || (( NEW_PORT < 1 || NEW_PORT > 65535 )); then
  echo "Error: port must be an integer between 1 and 65535." >&2
  exit 1
fi

# 3. Backup existing sshd_config
CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
echo "Backing up ${CONFIG_FILE} to ${BACKUP_FILE}..."
cp "$CONFIG_FILE" "$BACKUP_FILE"

# 4. Update Port directive
echo "Setting SSH port to ${NEW_PORT} in ${CONFIG_FILE}..."
#  - uncomment any existing Port lines and replace the number
#  - if no Port line exists, append one at the end
if grep -qE '^\s*#?\s*Port\s+' "$CONFIG_FILE"; then
  sed -ri "s|^\s*#?\s*Port\s+.*|Port ${NEW_PORT}|g" "$CONFIG_FILE"
else
  echo -e "\n# Listen on custom port\nPort ${NEW_PORT}" >> "$CONFIG_FILE"
fi

# 5. Restart SSH service
echo "Restarting SSH service..."
if systemctl is-active --quiet sshd; then
  systemctl restart sshd
else
  systemctl start sshd
fi

# 6. Remind about firewall
echo "Done! SSH is now listening on port ${NEW_PORT}."
echo "→ Make sure you allow port ${NEW_PORT} through your firewall (ufw, firewalld, iptables, etc.)."
echo "→ To test: ssh -p ${NEW_PORT} user@your_server_ip"
echo "Please reboot the system!!"
exit 0
