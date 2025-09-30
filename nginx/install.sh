
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
mkdir /mnt/sources
chown nginx:nginx /mnt/sources -R

# test nginx
# http://IP-HOST
