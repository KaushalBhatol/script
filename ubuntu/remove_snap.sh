#!/bin/bash
echo "remove every snap"
for s in $(snap list | awk 'NR>1 {print $1}'); do
  sudo snap remove --purge "$s"
done

echo "Stop and disable snapd"
sudo systemctl stop snapd.socket snapd.service
sudo systemctl disable snapd.socket snapd.service

echo "Purge snapd package"
sudo apt update
sudo apt purge --autoremove snapd

echo "Mask the snap mount unit"
sudo systemctl mask snapd.service
sudo systemctl mask snapd.socket
sudo systemctl mask snapd.seeded.service
sudo systemctl daemon-reload

echo "Clean up leftover directories"
sudo rm -rf /var/cache/snapd/
sudo rm -rf /snap
rm -rf ~/snap