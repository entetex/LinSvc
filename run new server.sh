#!/bin/bash
sudo -i

git clone https://github.com/entetex/LinSvc /tmp/git
rm -r /tmp/git/.git
mv /tmp/git/* /root/
chmod +x *.sh

./main.sh