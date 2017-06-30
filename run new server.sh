#!/bin/bash

git clone https://github.com/entetex/LinSvc /tmp/git
rm -r /tmp/git/.git
mv /tmp/git/* /root/
cd /root/
chmod +x *.sh

./main.sh