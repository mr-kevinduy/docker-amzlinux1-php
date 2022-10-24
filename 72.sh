#!/bin/bash

# Set timezone to Japan
sed -i -e "s/ZONE=\"UTC\"/ZONE=\"Japan\"/g" /etc/sysconfig/clock
ln -sf /usr/share/zoneinfo/Japan /etc/localtime

# Update and install packages
yum update -y && yum install -y \
  sudo \
  git \
  wget \
  nano \
  vim \
  telnet \
  htop \
  && yum clean all

# Pre install
yum remove -y httpd
yum remove -y httpd-tools

# Update and install packages
yum update -y && yum install -y httpd24
# yum update -y && yum install -y mysql57-server

# Update and install packages
yum install -y \
  php72 \
  php72-pdo \
  php72-mbstring \
  php72-xml \
  php72-json \
  php72-bcmath \
  php72-mysqlnd \
  && yum clean all

# ============ Install Composer, PHPCS
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --version=2.1.0
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Add user
useradd -m deploy
usermod -aG wheel deploy
usermod -aG wheel apache

sed -i "s|# %wheel  ALL=(ALL) NOPASSWD: ALL|%wheel  ALL=(ALL) NOPASSWD: ALL|g" /etc/sudoers
sed -i "s|#Group apache|Group wheel|g" /etc/httpd/conf/httpd.conf

mkdir -p /var/www/app/public
cat - << EOS > /var/www/app/public/index.html
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Index HTML</title>
    </head>
    <body>
        Index Page 
    </body>
</html>
EOS

chown -R apache:wheel /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# Setup serve
sed -i "s|#ServerName www\.example\.com:80|ServerName localhost:80|g" /etc/httpd/conf/httpd.conf

echo "NETWORKING=yes" > /etc/sysconfig/network

service httpd start
chkconfig httpd on

# ---------------- HTTPD ----------------
cat - << EOS > /etc/httpd/conf.d/localhost.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/app/public
    ErrorLog "/var/log/httpd/localhost-error.log"
    CustomLog "/var/log/httpd/localhost-access.log" common

    <Directory "/var/www/app/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOS

# service httpd restart

# ============ Install nodejs
curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs
npm install -g yarn
