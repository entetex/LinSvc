#!/bin/bash

# Verander naar Root
sudo -i

# Zet de Hostname in de Hosts file
# https://askubuntu.com/questions/59458/error-message-when-i-run-sudo-unable-to-resolve-host-none
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

# Upgrade de geinstalleerde packages
apt update
apt upgrade -y

# Maak Swap aan
# https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
SwapCheck="$(swapon --show | wc -l)"
if [ $SwapCheck -eq 0 ]
then
	# Swap bestaat niet
	# Swap aanmaken
	fallocate -l 4G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo "/swapfile none swap sw 0 0" >> /etc/fstab
else
	echo "Er was reeds een Swap file aangemaakt."
fi


#=====================================================#

# Salt Master
# https://docs.saltstack.com/en/latest/topics/installation/ubuntu.html
apt install salt-master -y

# Salt Master instellen
# https://docs.saltstack.com/en/latest/ref/configuration/index.html#configuring-salt

# Laat Salt via alle adressen luisteren
sed 's/#interface: 0.0.0.0/interface: 0.0.0.0/' /etc/salt/master
# Voeg de MASTER_ID toe, om naar de minions mee te geven
echo "master_id: SaltMaster_$HOSTNAME" >> /etc/salt/master

# Salt Master als daemon toevoegen
systemctl enable salt-master
# Start de Salt Master
systemctl start salt-master

#=====================================================#

# Salt Minion
# https://docs.saltstack.com/en/latest/topics/installation/ubuntu.html
apt install salt-minion -y

# Controleer het IP adres van de Salt Master
SaltMasterIP="$(cat config.cfg | grep SaltMasterIP)"
SaltMasterIP=${SaltMasterIP#SaltMasterIP=}
LocalIP="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
if [ $SaltMasterIP -eq $LocalIP ]
then
    # De Minion wordt ingesteld op de SaltMaster
    sed -i 's/#master: salt/master: 127.0.0.1/' /etc/salt/minion
else
    sed -i "s/#master: salt/master: $SaltMasterIP/" /etc/salt/minion
fi

# Stel de Master Key in
SaltMasterKey="$(cat config.cfg | grep SaltMasterKey)"
SaltMasterKey=${SaltMasterKey#SaltMasterKey=}
sed -i "s/#master_finger: ''/master_finger: $SaltMasterKey/" /etc/salt/minion

# Salt Minion als Daemon toevoegen
systemctl enable salt-minion
# Start Salt Minion
systemctl start salt-minion

# Start de server opnieuw op
