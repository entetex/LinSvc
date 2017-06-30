#!/bin/bash
# controlleert welke salt minions actief zijn om daarna te controlleren of deze ook actief zijn in Nagios

# https://stackoverflow.com/questions/5783375/evaluating-lines-from-stdout
# https://serverfault.com/questions/529049/how-do-i-list-all-connected-salt-stack-minions

# Selecteer de Hostnames voor alle werkende salt minions
salt-run manage.up | while read line; do
    # Controlleer of er een Nagios object bestaat met de desbetreffende hostname
    tmpMinionHostname=${line#- }
    checkVal="$(ls /usr/local/nagios/etc/objects/ | grep $tmpMinionHostname | wc -l)"
    if [ $checkVal -eq 0 ]
    then
        # Er bestaat nog geen config voor de minion.
        echo "Nagios host instellen voor $tmpMinionHostname" >> /root/LinSvc.log
        # Achterhaal met salt het ip adres van de minion
        # Ik veronderstel dat de if op Horizon altijd ens3 wordt
        tmpMinionIP="$(salt $tmpMinionHostname network.interface_ip ens3)"
        tmpMinionIP="$(echo $tmpMinionIP | sed 's/.* //')"
        # Kopieer een standaard configuratie naar de configs van Nagios en pas aan naar host
        mv /root/hosts.cfg /usr/local/nagios/etc/objects/$tmpMinionHostname.cfg
        sed -i "s/HostNameReplace/$tmpMinionHostname/g" /usr/local/nagios/etc/objects/$tmpMinionHostname.cfg
        sed -i "s/HostIPAddressReplace/$tmpMinionIP/g" /usr/local/nagios/etc/objects/$tmpMinionHostname.cfg
        # Voeg de config toe aan de hoofdconfiguratie van Nagios
        echo "cfg_file=/usr/local/nagios/etc/objects/$tmpMinionHostname.cfg" >> /usr/local/nagios/etc/nagios.cfg
        # Herstart Nagios
        systemctl restart nagios.service
    fi
done