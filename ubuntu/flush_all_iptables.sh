#!/bin/bash
set -e

echo "Flushing all existing iptables rules..."
sudo iptables -F

echo "Deleting all user-defined chains..."
sudo iptables -X

echo "Zeroing all packet and byte counters..."
sudo iptables -Z

echo "Stopping the iptables service..."
sudo systemctl stop iptables

echo "Disabling the iptables service on boot..."
sudo systemctl disable iptables

echo "Stopping netfilter-persistent service..."
sudo systemctl stop netfilter-persistent

echo "Disabling netfilter-persistent on boot..."
sudo systemctl disable netfilter-persistent

echo "Purging iptables package..."
sudo apt-get remove --purge iptables -y

echo "Purging netfilter-persistent package..."
sudo apt-get remove --purge netfilter-persistent -y

echo "Removing residual iptables configuration directory..."
sudo rm -rf /etc/iptables

echo "All iptables and netfilter-persistent components have been removed."
