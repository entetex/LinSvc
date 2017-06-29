#!/bin/bash
# Installatiescript voor Syslog-NG en Nagios

sudo -i

echo "Begin installatie van Syslog-NG" >> /root/LinSvc.log
# https://blog.webernetz.net/2014/07/24/basic-syslog-ng-installation/

apt install syslog-ng -y

# Config voorbeelden:
# https://wiki.archlinux.org/index.php/Syslog-ng
# https://www.balabit.com/documents/syslog-ng-ose-3.5-guides/en/syslog-ng-ose-guide-admin/html/index.html
# https://github.com/MatthijsBonnema/SaltStack/blob/master/logging.conf (Ja, ik heb van Matthijs afgekeken)
echo "Syslog-NG configuratie binnenharken en daemon instellen" >> /root/LinSvc.log
wget https://raw.githubusercontent.com/entetex/LinSvc/master/SyslogNGConf.conf /etc/syslog-ng/conf.d/SyslogNGConf.conf
