# ----------------------- Install Server Zabbix ----------------------------
# 1.
rpm -Uvh https://repo.zabbix.com/zabbix/7.4/release/rocky/10/noarch/zabbix-release-latest-7.4.el10.noarch.rpm
dnf clean all
dnf update -y

# 2. Install Zabbix server, frontend, agent2
dnf install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-agent2 -y

# 3. Install Zabbix agent 2 plugins
dnf install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql

# 4. Installing MariaDB Server

# 5 
mariadb -u root -p 
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'password';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
quit;

# 6. On Zabbix server host import initial schema and data. 
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mariadb --default-character-set=utf8mb4 -uzabbix -p zabbix

# Disable log_bin_trust_function_creators option after importing database schema.
mariadb -u root -p
set global log_bin_trust_function_creators = 0;
quit;

# 7. Configure the database for Zabbix server
# Edit file /etc/zabbix/zabbix_server.conf
vi /etc/zabbix/zabbix_server.conf
DBPassword=password

# 8. Start Zabbix server and agent processes
systemctl restart zabbix-server zabbix-agent httpd php-fpm
# 9. Start Zabbix server and agent processes and make it start at system boot.
systemctl enable zabbix-server zabbix-agent httpd php-fpm
systemctl status zabbix-server

# 10. Open Zabbix UI web page
# The default URL for Zabbix UI when using Apache web server is http://host/zabbi

# -------------- install zabbix agent 2 -----------------------------------------------------

# PhotonOs 
rpm -Uvh https://repo.zabbix.com/zabbix/7.2/release/rhel/9/noarch/zabbix-release-latest-7.2.el9.noarch.rpm
tdnf clean all
tdnf update
tdnf install zabbix-agent2

dnf install zabbix-get

systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

# set IP on Zabbix server
sed -i "s/Server=127.0.0.1/Server=127.0.0.1,192.168.53.47/g" /etc/zabbix/zabbix_agent2.conf

# set Hostname 
### Option: Hostname
#	List of comma delimited unique, case sensitive hostnames.
#	Required for active checks and must match hostnames as configured on the server.
#	Value is acquired from HostnameItem if undefined.
sed -i "s/Hostname=Zabbix Server/Hostname=HAProxyP43/g" /etc/zabbix/zabbix_agent2.conf

sed -i "s/# Plugins.Docker.Endpoint=unix:///var/run/docker.sock/Plugins.Docker.Endpoint=unix:///var/run/docker.sock/g" /etc/zabbix/zabbix_agent2.d/plugins.d/docker.conf

tail -f /var/log/zabbix/zabbix_agent2.log



# ------------ RockyLinux linux
rpm -Uvh https://repo.zabbix.com/zabbix/7.4/release/rocky/10/noarch/zabbix-release-latest-7.4.el10.noarch.rpm
dnf clean all
dnf update
dnf install zabbix-agent2


# set IP on Zabbix server
sed -i "s/Server=127.0.0.1/Server=192.168.53.47/g" /etc/zabbix/zabbix_agent2.conf

# set Hostname 
### Option: Hostname
#	List of comma delimited unique, case sensitive hostnames.
#	Required for active checks and must match hostnames as configured on the server.
#	Value is acquired from HostnameItem if undefined.
sed -i "s/Hostname=Zabbix Server/Hostname=HAProxyP43/g" /etc/zabbix/zabbix_agent2.conf

systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

