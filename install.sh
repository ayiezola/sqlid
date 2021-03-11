#!/bin/bash
cd ~

echo "Installing sqlid"
sudo apt install -y jq
cd sqlid/bin
sudo mv * /usr/local/bin
cd ~
mv -r sqlid /opt/
cd /opt/sqlid
chmod +x sqlid.sh
chmod +x uDork.sh
cp /opt/sqlid/.gf ~/.gf
cd /usr/local/bin
sudo ln -s /opt/sqlid/sqlid.sh sqlid
sudo ln -s /opt/sqlid/uDork.sh udork
