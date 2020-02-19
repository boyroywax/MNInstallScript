#!/bin/bash
# git clone https://github.com/boyroywax/boxy-k8s.git

# IP is set to get first private IP address or the Internal IP address on digital ocean
# IP="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')"
# MOUNTDIR="/mnt/"
# VOL="$(ls $MOUNTDIR | cut -f1 -d'/')"
MOUNT="/nfs"

# Update & upgrade the ubuntu install
sudo -s apt-get update
sudo -s apt-get upgrade -y
sudo -s apt-get autoremove -y
sudo -s apt-get autoclean -y

# Install nfs-server
sudo apt-get install -y nfs-kernel-server 

# Create a share directory
sudo mkdir -p $MOUNT

# Mount the digital ocean block volume to the mounted shared folder
sudo mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_volume-sfo2-01 $MOUNT

# NFS translates root operation to nobody:nogroup
sudo chown nobody:nogroup $MOUNT

# Configure a general purpose volume
sudo echo -e "$MOUNT\t*(rw,sync,no_subtree_check,insecure,all_squash)" >> /etc/exports

# Start the service
sudo systemctl restart nfs-kernel-server

# Enable the firewall
sudo ufw allow from any to any port nfs
sudo ufw allow ssh

# restart the firewall
sudo ufw disable
sudo ufw enable