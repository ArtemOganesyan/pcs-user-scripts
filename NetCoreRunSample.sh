#!/bin/bash
yum -y update
rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
yum -y install aspnetcore-runtime-5.0
yum -y install dotnet-sdk-5.0
yum -y install httpd
yum -y install git
echo "<VirtualHost *:80>
   ServerName www.DOMAIN.COM
   ProxyPreserveHost On
   ProxyPass / http://127.0.0.1:5000/
   ProxyPassReverse / http://127.0.0.1:5000/
   RewriteEngine on
   RewriteCond %{HTTP:UPGRADE} ^WebSocket$ [NC]
   RewriteCond %{HTTP:CONNECTION} Upgrade$ [NC]
   RewriteRule /(.*) ws://127.0.0.1:5000/$1 [P]
   ErrorLog /var/log/httpd/netcore-error.log
   CustomLog /var/log/httpd/netcore-access.log common
</VirtualHost>" > /etc/httpd/conf.modules.d/20-netcore.conf
service httpd start
mkdir /var/netcore
mkdir /var/netcore/source
cd /var/netcore/source
git clone https://github.com/ArtemOganesyan/pcs-webapp-main.git
cd /var/netcore/source/pcs-webapp-main/MainWebApp
mkdir /var/netcore/deployment
sudo dotnet publish -c Release -o /var/netcore/deployment
nohup /var/netcore/deployment/MainWebApp