
#--- Install php in Rocky linux 10
# https://wiki.crowncloud.net/?How_to_Install_LEMP_Stack_on_Rocky_Linux_10

dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm

dnf module switch-to php:remi-8.4

dnf module install php:remi-8.4

dnf install php-ctype \
  php-curl \
  php-dom \
  php-fileinfo \
  php-fpm \
  php-gd \
  php-intl \
  php-mbstring \
  php-mysqli \
  php-pdo_mysql \
  php-opcache \
  php-redis \
  php-openssl \
  php-phar \
  php-session \
  php-tokenizer \
  php-xml \
  php-xmlreader \
  php-xmlwriter \
  php-xdebug 


sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/;xdebug.mode = develop/xdebug.mode = develop,debug/g'  /etc/php.d/15-xdebug.ini

systemctl start php-fpm
systemctl enable php-fpm
# systemctl status php-fpm
# systemctl reload php-fpm
# php -v

systemctl restart nginx php-fpm

echo "<?php phpinfo() ?>" > /usr/share/nginx/html/info.php

# test PHP
# http://IP-HOST/info.php

