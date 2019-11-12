#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Please pass your App Server IP/DNS Name as an argument to the script"
exit 1
fi
set -x
####Install apache2
apt-get install apache2 -y
####Install apache2 module mod-jk
apt-get install libapache2-mod-jk -y
####Configure apache2
touch /etc/apache2/workers.properties
echo "worker.list=connect_geronimo
worker.connect_geronimo.port=8009
worker.connect_geronimo.host=$1
worker.connect_geronimo.type=ajp13" > /etc/apache2/workers.properties

sed -i 's/JkWorkersFile*.*/JkWorkersFile \/etc\/apache2\/workers.properties/' /etc/apache2/mods-available/jk.conf
sed -i 's/<\/VirtualHost\>/\tJkMount \/daytrader\/* connect_geronimo\n&/' /etc/apache2/sites-available/000-default.conf
service apache2 restart

exit 0