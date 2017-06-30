#!/bin/bash
echo "Geef de naam van de gewenste minion op:"
read minion

# Test de connectiviteit met de minion
conTest="$(salt joost-5 test.echo 'true' | grep True | wc -l)"
if [ conTest -eq 1 ]
then

    # Voer de deployment uit door middel van composer, door middel van salt
    salt $minion cmd.run '/root/deployWP.sh'

    # Voeg een HTTP check uit in Nagios
    echo "define service{" >> /usr/local/nagios/etc/objects/$minion.cfg
    echo "    use                     generic-service" >> /usr/local/nagios/etc/objects/$minion.cfg
    echo "    host_name               $minion" >> /usr/local/nagios/etc/objects/$minion.cfg
    echo "    service_description     HTTP Check" >> /usr/local/nagios/etc/objects/$minion.cfg
    echo "    check_command           check_http!" >> /usr/local/nagios/etc/objects/$minion.cfg
    echo "}" >> /usr/local/nagios/etc/objects/$minion.cfg
else
    echo "Deze minion bestaat niet, of is onbereikbaar!"
fi