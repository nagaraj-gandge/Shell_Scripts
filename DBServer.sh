#!/bin/bash
set -x

####Install MySQL Server

debconf-set-selections <<< 'mysql-server mysql-server/root_password password mysql'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mysql'
apt-get install mysql-server -y

####Configure MySQL
sed -i 's/bind-address*.*/# bind-address           = 127.0.0.1/' /etc/mysql/my.cnf
service mysql restart

####Create Daytrader Database and User
mysql -h localhost -u root -pmysql -e "create database tradedb;" 
mysql -h localhost -u root -pmysql -e "CREATE USER 'daytrader'@'%' IDENTIFIED BY 'daytrader';"
mysql -h localhost -u root -pmysql -e "GRANT ALL PRIVILEGES ON tradedb.* TO daytrader IDENTIFIED BY 'daytrader';"
