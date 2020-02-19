#!/bin/bash
# git clone https://github.com/boyroywax/boxy-k8s.git

if [ $# -ne 1 ]; then
    echo $0: usage: node setup
    exit 1
fi

NODENUM=$1
DOCKERUSER=ubuntu
DOCKERVERSION=17.03.2~ce-0~ubuntu-xenial

# Update & upgrade the ubuntu install
sudo -s apt-get update
sudo -s apt-get upgrade -y
sudo -s apt-get autoremove -y
sudo -s apt-get autoclean -y

# Remove old install of docker
sudo apt-get remove docker docker-engine docker.io containerd runc

# Set up the official docker repo
# update first
sudo apt-get update

# install prereqs for docker-ce 
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add docker official GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Check to see if the GPG key matches
# sudo apt-key fingerprint 0EBFCD88

# add STABLE repository for our architecture
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker-CE v17.03.2
# update after adding repository above
sudo apt-get update

# install v17.03.2
sudo apt-get install -y docker-ce=$DOCKERVERSION containerd.io

# alternative install - https://stackoverflow.com/questions/51705097/cannot-install-docker-version-17-03-2-from-ubuntu-bionic-18-04-server
# docker-ce depends on libltdl7 (>= 2.4.6)
# wget http://archive.ubuntu.com/ubuntu/pool/main/libt/libtool/libltdl7_2.4.6-6_amd64.deb
# sudo dpkg -i libltdl7_2.4.6-6_amd64.deb
# wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_17.03.2~ce-0~ubuntu-xenial_amd64.deb
# sudo dpkg -i docker-ce_17.03.2~ce-0~ubuntu-xenial_amd64.deb

# create directory for ssh key - https://www.digitalocean.com/community/questions/ubuntu-16-04-creating-new-user-and-adding-ssh-keys
mkdir -p /home/$DOCKERUSER/.ssh

# Create Authorized Keys File
touch /home/$DOCKERUSER/.ssh/authorized_keys

# copy public key into authorized keys
cp /root/boxy-k8s/rancher/node$NODENUM/id_rsa.pub /home/$DOCKERUSER/.ssh/
cat /home/$DOCKERUSER/.ssh/id_rsa.pub >> /home/$DOCKERUSER/.ssh/authorized_keys

# Create User + Set Home Directory
useradd -d /home/$DOCKERUSER -s /bin/bash $DOCKERUSER

# Add User to sudo Group
usermod -aG sudo $DOCKERUSER

# Set Permissions
chown -R $DOCKERUSER:$DOCKERUSER /home/$DOCKERUSER/
chown root:root /home/$DOCKERUSER
chmod 700 /home/$DOCKERUSER/.ssh
chmod 644 /home/$DOCKERUSER/.ssh/authorized_keys

# Create the Docker Group
sudo groupadd docker

# add the user to the docker group
sudo usermod -aG docker $DOCKERUSER

# Set Docker to load on startup
sudo systemctl enable docker


# Check the storage driver of Docker
# Code from - https://blog.programster.org/ubuntu-16-04-ensure-docker-running-overlay2-storage-driver
# # stop docker
# sudo systemctl stop docker

# # create a backup of existing setup
# sudo cp -au /var/lib/docker /var/lib/docker.bk

# # Create the docker deamon config to tell docker to use overlay2
# echo '{ "storage-driver": "overlay2" }' | sudo tee /etc/docker/daemon.json

# # Start docker
# sudo systemctl start docker

