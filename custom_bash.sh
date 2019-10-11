#!/bin/sh
echo $(date) + "Cloud-init custom data installing ..." >> /tmp/myScript.txt
whoami >> /tmp/myScript.txt >> /tmp/myScript.txt
tdnf -y update >> /tmp/myScript.txt >> /tmp/myScript.txt
tdnf -y install tar icu libunwind unzip wget >> /tmp/myScript.txt
mkdir ~/photonosonazure >> /tmp/myScript.txt
wget https://github.com/dcasota/photonosonazure/archive/master.zip >> /tmp/myScript.txt
unzip master.zip -d ~/photonosonazure >> /tmp/myScript.txt
cd ~/photonosonazure/photonosonazure-master >> /tmp/myScript.txt
chmod a+x ./PwshGalleryonPhotonOS.sh >> /tmp/myScript.txt
./PwshGalleryonPhotonOS.sh >> /tmp/myScript.txt
cd / >> /tmp/myScript.txt
rm /master.zip >> /tmp/myScript.txt
rm -r ~/photonosonazure >> /tmp/myScript.txt
echo $(date) + "Cloud-init custom data installed." >> /tmp/myScript.txt

