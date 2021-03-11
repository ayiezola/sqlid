#!/bin/bash
cd ~

echo "Installing sqlid"
sudo apt install -y jq
git clone https://github.com/zam6098/sqlid.git
cd sqlid/bin
mv * /usr/local/bin

mv -r sqlid /opt/

cd /usr/local/bin
chmod +x sqlid.sh
sudo ln -s /opt/sqlid/sqlid.sh sqlid
sudo ln -s /opt/sqlid/uDork.sh udork
