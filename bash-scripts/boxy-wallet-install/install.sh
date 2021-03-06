#/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
MAX=9

COINGITHUB=https://github.com/BOXYCoinFoundation/boxycoin.git
COINGITFOLDER=boxycoin
COINPORT=121524
COINRPCPORT=121526
COINDAEMON=boxyd
COINCORE=.boxy
COINCONFIG=boxy.conf

checkForUbuntuVersion() {
   echo "[1/${MAX}] Checking Ubuntu version..."
   sleep 3
    if [[ `cat /etc/issue.net`  == *16.04* ]]; then
        echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
    else
        echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
        echo && echo "Installation cancelled" && echo;
        exit;
    fi
}

changeSsh() {
    echo
    echo "[2/${MAX}] Runing update and upgrade. Please wait..."
    sleep 3
#    echo "ClientAliveInterval 600" >> 
#TCPKeepAlive yes
#ClientAliveCountMax 10
}

updateAndUpgrade() {
    echo
    echo "[3/${MAX}] Runing update and upgrade. Please wait..."
    sleep 3
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null 2>&1
    echo -e "${GREEN}* Done${NONE}";
}

installFirewall() {
    echo
    echo -e "[4/${MAX}] Installing UFW. Please wait..."
    sleep 3
    sudo apt-get -y install ufw > /dev/null 2>&1
    sudo ufw default deny incoming > /dev/null 2>&1
    sudo ufw default allow outgoing > /dev/null 2>&1
    sudo ufw allow ssh > /dev/null 2>&1
    sudo ufw limit ssh/tcp > /dev/null 2>&1
    sudo ufw allow $COINPORT/tcp > /dev/null 2>&1
    sudo ufw allow $COINRPCPORT/tcp > /dev/null 2>&1
    sudo ufw logging on > /dev/null 2>&1
    echo "y" | sudo ufw enable > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installSwap() {
    echo
    echo -e "[5/${MAX}] Installing SwapFile. Please wait..."
    sleep 3
    sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=1000 > /dev/null 2>&1
    sudo mkswap /var/swap.img > /dev/null 2>&1
    sudo swapon /var/swap.img > /dev/null 2>&1
    sudo chmod 0600 /var/swap.img > /dev/null 2>&1
    sudo chown root:root /var/swap.img > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installDependencies() {
    echo
    echo -e "[6/${MAX}] Installing dependencies. Please wait..."
    sleep 3
    sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake -qq -y > /dev/null 2>&1
    sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libgmp-dev -qq -y > /dev/null 2>&1
    sudo apt-get install openssl -qq -y > /dev/null 2>&1
    sudo apt-get install software-properties-common -qq -y > /dev/null 2>&1
    sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
    sudo apt-get update -qq -y > /dev/null 2>&1
    sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libgmp3-dev -y > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installWallet() {
    echo
    echo -e "[7/${MAX}] Installing wallet. Please wait, you can take your dog for a walk, this may take 20-30 min"
    sleep 3
    git clone $COINGITHUB > /dev/null 2>&1
    cd ~/$COINGITFOLDER/src/leveldb > /dev/null 2>&1
    wget https://github.com/google/leveldb/archive/v1.18.tar.gz > /dev/null 2>&1
    tar xfv v1.18.tar.gz > /dev/null 2>&1
    cp leveldb-1.18/Makefile ~/$COINGITFOLDER/src/leveldb/ > /dev/null 2>&1
    chmod +x build_detect_platform > /dev/null 2>&1
    cd > /dev/null 2>&1
    cd ~/$COINGETFOLDER/src > /dev/null 2>&1
    sudo make -f makefile.unix USE_UPNP=- > /dev/null 2>&1
    chmod 755 $COINDAEMON > /dev/null 2>&1
    strip $COINDAEMON > /dev/null 2>&1
    sudo mv $COINDAEMON /usr/bin > /dev/null 2>&1
    cd > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

startWallet() {
    echo
    echo -e "[8/${MAX}] Starting wallet daemon..."
    sleep 3
    sudo mkdir ~/$COINCORE > /dev/null 2>&1
    cd ~/$COINCORE > /dev/null 2>&1
    sudo rm governance.dat > /dev/null 2>&1
    sudo rm netfulfilled.dat > /dev/null 2>&1
    sudo rm peers.dat > /dev/null 2>&1
    sudo rm -r blocks > /dev/null 2>&1
    sudo rm mncache.dat > /dev/null 2>&1
    sudo rm -r chainstate > /dev/null 2>&1
    sudo rm fee_estimates.dat > /dev/null 2>&1
    sudo rm mnpayments.dat > /dev/null 2>&1
    sudo rm banlist.dat > /dev/null 2>&1
    sudo touch ~/$COINCORE/$COINCONFIG > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Add your masternode configuration and save. Press "control x" after "y" and "enter". Wait a few seconds, now the editor will open. ${NONE}";
    sleep 10 
    nano $COINCONFIG
    cd > /dev/null 2>&1
    $COINDAEMON -daemon > /dev/null 2>&1
    cd ~ > /dev/null 2>&1
    echo -e "${GREEN}* Done${NONE}";
}

syncWallet() {
    echo
    echo "[9/${MAX}] Waiting for wallet to sync.";
    sleep 3
    echo -e "${GREEN}* Blockchain Synced${NONE}";
    echo -e "${GREEN}* Masternode List Synced${NONE}";
    echo -e "${GREEN}* Winners List Synced${NONE}";
    echo -e "${GREEN}* Done reindexing wallet${NONE}";
}

clear
cd

echo
echo -e "-----------------------------------------------------------------------------"
echo -e "|                                                                           |"
echo -e "|   ${BOLD}----- BOXY Coin Ubuntu Install script -----$ {NONE}              |"
echo -e "|                                                                           |"
echo -e "|           ${CYAN}d8888b.  .d88b.  db    db db    db      ${NONE}          |" 
echo -e "|           ${CYAN}88  `8D .8P  Y8. `8b  d8' `8b  d8'      ${NONE}          |"                   
echo -e "|           ${CYAN}88oooY' 88    88  `8bd8'   `8bd8'       ${NONE}          |"
echo -e "|           ${CYAN}88~~~b. 88    88  .dPYb.     88         ${NONE}          |"
echo -e "|           ${CYAN}88   8D `8b  d8' .8P  Y8.    88         ${NONE}          |"
echo -e "|           ${CYAN}Y8888P'  `Y88P'  YP    YP    YP         ${NONE}          |"
echo -e "|                                                                           |"
echo -e "-----------------------------------------------------------------------------"

echo -e "${BOLD}"
read -p "This script will setup your BOXY Coin Ubuntu 16.04 Wallet (CommandLine Only). Do you wish to continue? (y/n)? " response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    checkForUbuntuVersion
    updateAndUpgrade
    installFirewall
    installSwap
    installDependencies
    installWallet
    startWallet
    syncWallet

    echo
    echo -e "${BOLD}The VPS side of your masternode has been installed${NONE}".
    echo -e "${BOLD}Happy mining¡¡¡¡.${NONE}".
    echo 
    echo -e "${CYAN}Script By SoyBtc - Modified by boyroywax${NONE}".
    echo
    else
    echo && echo "Installation cancelled" && echo
fi
