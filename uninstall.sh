#!/usr/bin/env bash

# Stop all instances of the service
sudo systemctl stop 'ratholes@*.service'
sudo systemctl stop Reversed_Server.service
sudo systemctl disable Reversed_Server.service
sudo rm -rf /root/.config/reversed_server
sudo rm /etc/systemd/system/Reversed_Server.service
sudo rm -rf /root/.reversed_server


# Disable all instances of the service
for service in $(sudo systemctl list-unit-files --type=service | grep 'ratholes@' | awk '{print $1}'); do
    sudo systemctl disable "$service"
done

# Remove service files for all instances
sudo rm /etc/systemd/system/ratholes@*.service
