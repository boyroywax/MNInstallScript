# CDZC-MN-Install
Simple install script for CryptoDezire Cash MasterNode Installation on Ubuntu 18.04

# Steps

Create a Ubuntu 18.04 VPS with at least 1GB of RAM on your Favorite Cloud Hosting Service (Digital Ocean, Vultr, etc.)

It is recommended you create an SSH key pair and add that to your VPS for proper security.

Log into your VPS then type the following commands:

    git clone  https://github.com/boyroywax/CDZC-MN-Install.git

    cd CDZC-MN-Install

    chmod +x install.sh

    ./install.sh

The Script will automatically pull a cryptodezirecash.conf with the latest addnodes.  All you need to is do is add your Masternode Genkey to the conf file then press:

    CTRL + o
    press ENTER
    CTRL + x
    
The Wallet info panel should now be displayed and the installation is finished.  If you have any questions please ask @lowerj#4148 on Discord.
