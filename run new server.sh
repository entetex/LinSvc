#!/bin/bash
sudo -i

wget https://raw.githubusercontent.com/entetex/LinSvc/master/config.cfg /root/config.cfg
wget https://raw.githubusercontent.com/entetex/LinSvc/master/main.sh /root/main.sh

chmod +x main.sh

./main.sh