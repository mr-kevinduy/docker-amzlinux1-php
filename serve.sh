#!/bin/bash
#

vthost="<VirtualHost $1>
    ServerName $2
    DocumentRoot $3
    ErrorLog "/var/log/httpd/$2-error.log"
    CustomLog "/var/log/httpd/$2-access.log" common

    <Directory $3>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
"
echo "$vthost" > "/etc/httpd/conf.d/$2.conf"
