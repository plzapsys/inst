
# dnf module list mariadb
# dnf -qy module disable mariadb
# dnf module reset mariadb -y

curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.8
dnf config-manager --set-disabled mariadb-maxscale

dnf -y repolist
dnf install MariaDB-server MariaDB-client
mariadb -V

mkdir /var/log/mariadb
touch /var/log/mariadb/mariadb.log
touch /var/log/mariadb/mariadb-slow.log
chmod 644 /var/log/mariadb/mariadb.log
chmod 644 /var/log/mariadb/mariadb-slow.log

# systemctl enable --now mariadb  => only sigle Server
systemctl start mariadb
systemctl status mariadb

mariadb-secure-installation

# Enable Remote access 
sudo sed -i 's/#bind-address=0.0.0.0/bind-address=0.0.0.0/g' /etc/my.cnf.d/server.cnf
mariadb -u root -p 
GRANT ALL ON *.* to 'root'@'%' IDENTIFIED BY 'PASSWORD' WITH GRANT OPTION;
flush privileges;

#Create a new database:
create database DATABASE_NAME character set utf8mb4 collate utf8mb4_unicode_ci;

# Create a new user (only with local access) and grant privileges to this user on the new database:
grant all privileges on DATABASE_NAME.* TO 'USER_NAME'@'localhost' identified by 'PASSWORD';
#Create a new user (with remote access) and grant privileges to this user on the new database:
grant all privileges on DATABASE_NAME.* TO 'USER_NAME'@'%' identified by 'PASSWORD';
#After modifying the MariaDB grant tables, execute the following command in order to apply the changes:
flush privileges;
