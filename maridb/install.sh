
# dnf module list mariadb
# dnf -qy module disable mariadb
# dnf module reset mariadb -y
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.8
dnf config-manager --set-disabled mariadb-maxscale

dnf -y repolist
dnf install MariaDB-server MariaDB-client rsync
mariadb -V

# systemctl enable --now mariadb  => only sigle Server
systemctl start mariadb
systemctl status mariadb

mariadb-secure-installation

# view log maridb 
journalctl -xeu mariadb

# Io_uring enabling
# create file 
touch /etc/sysctl.d/io_uring.conf
echo "kernel.io_uring_disabled=0" >> /etc/sysctl.d/io_uring.conf
sysctl --system

# /etc/security/limits.conf
echo "" >> /etc/security/limits.conf
echo "" >> /etc/security/limits.conf
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf
sysctl -p
exit
# login on console
ulimit -n

# fix unset environment variable evaluates to an empty string
touch  /etc/systemd/system/mariadb.service.d/override.conf
echo "[Service]" >> /etc/systemd/system/mariadb.service.d/override.conf
echo "Environment="MYSQLD_OPTS="" >> /etc/systemd/system/mariadb.service.d/override.conf
echo "Environment="_WSREP_NEW_CLUSTER="" >> /etc/systemd/system/mariadb.service.d/override.conf

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

# ----- backup -----------------------------------------
BACKUP1="solar-$(date '+%Y-%m-%d_%H:%M:%S')";
mariadb-dump \
  --user=user \
  --password=password \
  --host=192.168.23.110 \
  --port=53306 \
  --databases solar \
  --result-file=/mnt/solar.sql \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --hex-blob \
  --no-create-db \
  --skip-ssl


# if import solar to testsolar or develosolar 
sed -e 's/USE `solar`;/USE `testsolar`;/g' -i /mnt/solar.sql
sed -e 's/USE `solar`;/USE `develosolar`;/g' -i /mnt/solar.sql

# ---- convert ----------------------------------
# remove DEFAULT CHARSET
sed -e 's/DEFAULT CHARSET=utf8//g' -i /mnt/solar.sql
# ------ restore -------------------------------------------------
mariadb -u root -p solar < solar.sql

# -------------------- check Character ---------------------------------
# Determine Current Character Set & Collation
SELECT
	s.SCHEMA_NAME,
	s.DEFAULT_CHARACTER_SET_NAME,
	s.DEFAULT_COLLATION_NAME,
	t.TABLE_NAME,
	t.TABLE_COLLATION,
	ccsa.CHARACTER_SET_NAME,
	c.COLUMN_NAME,
	c.CHARACTER_SET_NAME,
	c.COLLATION_NAME
FROM
	information_schema.SCHEMATA s
LEFT JOIN information_schema.TABLES t ON
	s.SCHEMA_NAME = t.TABLE_SCHEMA
LEFT JOIN information_schema.COLLATION_CHARACTER_SET_APPLICABILITY ccsa ON
	t.TABLE_COLLATION = ccsa.COLLATION_NAME
LEFT JOIN information_schema.COLUMNS c ON
	s.SCHEMA_NAME = c.TABLE_SCHEMA
	AND t.TABLE_NAME = c.TABLE_NAME
WHERE
	s.schema_name = 'demo' ORDER BY COLLATION_NAME DESC;
# -----------------------------------------------------------------------------

# -- database
ALTER DATABASE database_name CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
# -- for each table (also converts columns within table)
# -- USE
ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
# ---------------------------------------------------------------------------------------

SELECT CONCAT('ALTER TABLE `', table_name, '` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
FROM information_schema.tables
WHERE table_schema = 'your database name here'
  AND table_type = 'BASE TABLE';

The output of this query you can run again to change the tables
# ----------------------------------------------------------------------------



