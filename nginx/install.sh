
#----- Install nginx  in Rocky linux 10 ---------------------------------------
dnf install nginx -y
systemctl start nginx
systemctl enable nginx
# systemctl status nginx
# nginx -v
# journalctl -xeu nginx

# ssl certificates
openssl req -x509 -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/nginx.key -out /etc/pki/tls/certs/nginx.crt -days 3650 -sha256 -subj '/CN=localhost'  
openssl dhparam -out /etc/pki/tls/certs/dhparam.pem 2048
chown -R nginx:nginx /etc/pki/tls/private/nginx.key
chmod 600 /etc/pki/tls/private/nginx.key

chown nginx:nginx /usr/share/nginx/html -R
# test nginx
# http://IP-HOST

# -------- create strukture site-01 ------------------
mkdir /mnt/sources
mkdir /mnt/sources/site-01
mkdir /mnt/sources/site-01/log
mkdir /mnt/sources/site-01/www

echo "<?php phpinfo(); ?>" > /mnt/sources/site-01/www/info.php
echo "<?php echo "site-01"; ?>" > /mnt/sources/site-01/www/index.php
echo "<p> site-01 </p>" > /mnt/sources/site-01/www/index.html

touch /mnt/sources/site-01/log/error.log
touch /mnt/sources/site-01/log/xdebug.log

chown nginx:nginx /mnt/sources -R

# http://IP-HOST:8001
# https://IP-HOST:44301

