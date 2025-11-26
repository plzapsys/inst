

timedatectl set-timezone Europe/Sofia

sed -i "s/AllowTcpForwarding no/AllowTcpForwarding yes/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config
# systemctl restart sshd
sed -i 's/WAIT_OPTIONS="--wait 1 --wait-interval 20000"/WAIT_OPTIONS="--wait 1"/g' /etc/systemd/scripts/iptables
# sed -i "s/DHCP=yes/DHCP=no/g" /etc/systemd/network/99-dhcp-en.network
sudo sed -i '/^Gateway=/i\[Route]\nDestination=0.0.0.0/0' /etc/systemd/network/50-static-en.network
# tdnf check-update
# tdnf clean all
# tdnf distro-sync

tdnf -y update
tdnf -y install wget htop tar mc git rsync nfs-utils tcpdump netcat cronie chrony
# tdnf -y install traceroute wireshark  bindutils docker docker-compose

systemctl enable --now chronyd

systemctl enable crond
systemctl start crond

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZAz6hJzLPHL6B+6jAkSg6JiuXT64++fjviRknBcUWMwhBSFTWPWHOXXrHBkBpoMZ3MOF3WKZTsAMZRgtNq7h1pk4D0m25Wb2i3bRUTKntao7tQ1SUETjnnBt6w311RBPUcm/YZsVoycZZeGTtH8Gn/6Wi/RviD2NmhgyRfoFaDDT+DKOp/TC2/J/kbWCPBlIAbGQn/dUUoPLA9eEQxuG6nowrx1Rv4/317LW3Fmg0cP7nHiKx3nXkrT9VwBV6w6uxmMRtiy6Nvg9OnzIG4gCo1B5nHWmsbOBfUPQKks6UAbcyaOF+lc65iWge8mpLOhl5M9javWjlI8s/g41H6MTRCkpch0mkEQuK3BOKkGR356x9BugpyMWVhqhSjcP47w6L+/qytJR/8eZwn6Y8NWNwLiVqAQkQYZCr6WHZAE6s5fs1XrHb3WgyI1fCRhfITSZYjRAl/uJIFkjQMeUtmPiW0sRyRJTgIy6EaFRKIjbTuYACHXK1fqvIcNjbu/MojXs= usname" > /root/.ssh/authorized_keys

wget -P /etc/profile.d/ https://raw.githubusercontent.com/plzapsys/inst/main/profile_show.sh
chmod +x /etc/profile.d/profile_show.sh

# Removing Password Expiration Policy
chage -I -1 -m 0 -M 99999 -E -1 root

# Restart
history -c
shutdown -r now


# ---- crontab ---------------------
# crontab -e
# i
# Paste => 15 00 * * * /mnt/container/scripts/getcert.sh >/mnt/container/scripts/log/getcert_15_00.log 2>&1
# esc
# :wq
# systemctl restart crond
# crontab -l

#  minute hour dayofmonth month  dayofweek
#  0-59   0-23 1-31       1-12   0-7, where 0 or 7 is Sunday, 1 is Monday, and so on


# ----------- iptables ----------------------------------------
#  if use iptablse
# /etc/systemd/scripts/ip4save
# Disable Firewall
# iptables --list
# systemctl stop iptables
# systemctl disable iptables
# systemctl restart systemd-networkd
# iptables --list

##### Allow ICMP echo responses
# iptables -A OUTPUT -p icmp -j ACCEPT
# iptables -A INPUT -p icmp -j ACCEPT
# Allow port
# iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

####### Allow port
# - HAProxyBackup ---------------------------------------
# sed -i "s/-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT/#-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT/g" /etc/systemd/scripts/ip4sav
# iptables -A INPUT --source x.x.x.x/28 -p tcp -m tcp --dport 22 -j ACCEPT
# iptables -A INPUT --source x.x.x.x/28 -p tcp -m tcp --dport 8404 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# iptables-save > /etc/systemd/scripts/ip4save
# systemctl restart iptables
# systemctl daemon-reload
# - JITSI ---------------------------------------------
# sed -i "s/-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT/#-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT/g" /etc/systemd/scripts/ip4save
# iptables -A INPUT --source x.x.x.x/28 -p tcp -m tcp --dport 22 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 8000 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 8280 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 5222 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 5347 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 5280 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# iptables -A INPUT -p udp -m udp --dport 443 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 8443 -j ACCEPT
# iptables -A INPUT -p udp -m udp --dport 1000 -j ACCEPT
# iptables-save > /etc/systemd/scripts/ip4save
# systemctl restart iptables
# systemctl daemon-reload
# ------------------------------------------------------
# iptables --list
# iptables -L

# --------- for JITS ------------------------
# sed -i 's/#DefaultLimitNOFILE=1024:524288/DefaultLimitNOFILE=65000/g' /etc/systemd/system.conf
# sed -i 's/#DefaultLimitNPROC=/DefaultLimitNPROC=65000/g' /etc/systemd/system.conf
# sed -i 's/#DefaultTasksMax=15%/DefaultTasksMax=75%/g' /etc/systemd/system.conf

# --------------Command PhotonOS------------------------------------------------------------------
# https://medium.com/@lubomir-tobek/useful-basic-photon-os-commands-000011b53b61
# https://medium.com/@lubomir-tobek/useful-advanced-photon-os-commands-troubleshooting-85c6e4564555
# ---------- Resize System disk -----------
# https://codenotary.com/blog/resize-photon-os-system-disk
# https://medium.com/@lubomir-tobek/useful-basic-photon-os-commands-000011b53b61

# Finding version of Photon OS
# cat /etc/photon-release

# --------- Platform -------------------------------------------------------------------------------------------
# tdnf -y install openjdk17
# mkdir /mnt/general
# mkdir /mnt/documents
# mkdir /mnt/sftp
# test => mount -t nfs 192.168.53.70:/PNFS /mnt/hgfs
# echo "192.168.53.70:/PNFS/general      /mnt/general               nfs4     defaults        0 0" >> /etc/fstab
# echo "192.168.53.70:/PNFS/documents    /mnt/documents             nfs4     defaults        0 0" >> /etc/fstab
# echo "192.168.53.70:/PNFS/sftp         /mnt/sftp                  nfs4     defaults        0 0" >> /etc/fstab
# ------------------------------------------------------------------------------------------------------------------

# rsync 
# rsync --stats -arvzh --progress root@192.168.43.5:/root/containers/cert /mnt/container/

# ----------------------------------------------
# cdm dns
# ipconfig /flushdns
# ----------------------------------------------------------------



