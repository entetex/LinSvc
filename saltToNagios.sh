#!/bin/bash
# controlleert welke salt minions actief zijn om daarna te controlleren of deze ook actief zijn in Nagios

# https://stackoverflow.com/questions/5783375/evaluating-lines-from-stdout
# https://serverfault.com/questions/529049/how-do-i-list-all-connected-salt-stack-minions

salt-run manage.up | while read line; do
    tmpMinionHostname=${line#- }
    checkVal="$(ls /usr/local/nagios/etc/objects/ | grep $tmpMinionHostname | wc -l)"
    if [ $checkVal -eq 0 ]
    then
        echo "Nagios host instellen voor $tmpMinionHostname" >> /root/LinSvc.log
        tmpMinionIP="$(salt $tmpMinionHostname network.interface_ip ens3)"
        tmpMinionIP="$(echo $tmpMinionIP | sed 's/.* //')"
        mv /root/hosts.cfg /usr/local/nagios/etc/objects/$tmpMinionHostname.cfg
        sed -i "s/HostNameReplace/$tmpMinionHostname/g" /usr/local/nagios/etc/objects/$tmpMinionHostname.cfg
        sed -i "s/HostIPAddressReplace/$tmpMinionIP/g" /usr/local/nagios/etc/objects/$tmpMinionHostname.cfg
        echo "cfg_file=/usr/local/nagios/etc/objects/$tmpMinionHostname.cfg" >> /usr/local/nagios/etc/nagios.cfg
        systemctl restart nagios.service
    else
        echo "Config present voor $tmpMinionHostname"
    fi
done