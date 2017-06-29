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
echo "Syslog-NG configuratie binnenharken en opnieuw starten" >> /root/LinSvc.log
wget https://raw.githubusercontent.com/entetex/LinSvc/master/SyslogNGConf.conf -P /etc/syslog-ng/conf.d/
systemctl restart syslog-ng
# Blijkbaar wordt ie standaard als daemon toegevoegd.


#=========================================================================#
# Nagios install
# https://support.nagios.com/kb/article/nagios-core-installing-nagios-core-from-source.html#Ubuntu
# https://www.digitalocean.com/community/tutorials/how-to-install-nagios-4-and-monitor-your-servers-on-ubuntu-14-04
echo "Begin installatie van Nagios" >> /root/LinSvc.log
apt install -y autoconf gcc make apache2 php libapache2-mod-php7.0 libgd2-xpm-dev
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.3.2.tar.gz
tar xzf nagioscore.tar.gz

echo "Nagios bronbestanden binnen, Start compilatie" >> /root/LinSvc.log

cd /tmp/nagioscore-nagios-4.3.2/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all

echo "Nagios gebruiker toevoegen" >> /root/LinSvc.log
useradd nagios
usermod -a -G nagios www-data

echo "Nagios installeren" >> /root/LinSvc.log
make install
make install-init
update-rc.d nagios defaults
make install-commandmode
sudo make install-config

echo "Nagios webcomponenten installeren" >> /root/LinSvc.log
make install-webconf
a2enmod rewrite
a2enmod cgi

htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin GeheimWachtwoort

echo "Nagios webserver opnieuw opstarten" >> /root/LinSvc.log
systemctl restart apache2.service

echo "Nagios service starten en instellen als daemon" >> /root/LinSvc.log
systemctl start nagios.service
systemctl enable nagios.service

echo "Nagios Core afgerond" >> /root/LinSvc.log
echo "" >> /root/LinSvc.log
echo "Nagios Plugins" >> /root/LinSvc.log
echo "Nagios Plugins Deps installeren" >> /root/LinSvc.log
apt-get install -y libmcrypt-dev libssl-dev bc dc snmp libnet-snmp-perl gettext

echo "Nagios Plugins Source downloaden" >> /root/LinSvc.log
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz

echo "Nagios Plugins Source compileren in installeren" >> /root/LinSvc.log
cd /tmp/nagios-plugins-release-2.2.1/
./tools/setup
./configure
make
make install

echo "Nagios SNMPd Stel hosts en services in" >> /root/LinSvc.log
wget https://raw.githubusercontent.com/entetex/LinSvc/master/objects/hosts.cfg -P /usr/local/nagios/etc/
echo "cfg_file=/usr/local/nagios/etc/objects/hosts.cfg" >> /usr/local/nagios/etc/nagios.cfg

systemctl restart nagios.service
echo "Nagios Plugins voltooid" >> /root/LinSvc.log