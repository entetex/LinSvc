#!/bin/bash

# Installatie van Docker
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#recommended-extra-packages-for-trusty-1404

echo "BEGIN DOCKER" >> /root/LinSvc.log

apt-get update
apt-get install apt-transport-https ca-certificates curl software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
DockerPGPKey="$(apt-key fingerprint 0EBFCD88 | grep fingerprint)"
DockerPGPKey=${DockerPGPKey#Key fingerprint = }
DockerPGPKey="$(echo $DockerPGPKey | cut -d "=" -f2- | cut -d " " -f2-)"
DefaultKey="9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"
if [ "$DockerPGPKey" == "$DefaultKey" ]
then
    echo "De sleutels zijn gelijk" >> /root/LinSvc.log
else
    echo "De sleutels komen niet overeen!" >> /root/LinSvc.log
    echo "Het script wordt afgebroken." >> /root/LinSvc.log
    exit 1
fi

echo "Voeg Docker repo toe" >> /root/LinSvc.log
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update

echo "Start installatie van docker" >> /root/LinSvc.log
apt install docker-ce docker-compose -y

# Post installatie
# https://docs.docker.com/engine/installation/linux/linux-postinstall/#manage-docker-as-a-non-root-user
echo "Stel group en users in" >> /root/LinSvc.log
# Is wellicht niet nodig, sinds salt werkt vanaf root
groupadd docker
usermod -aG docker ubuntu

echo "Stel docker in als daemon" >> /root/LinSvc.log
systemctl enable docker

echo "Docker installatie voltooid" >> /root/LinSvc.log