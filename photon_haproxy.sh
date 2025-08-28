

timedatectl set-timezone Europe/Sofia
sed -i "s/AllowTcpForwarding no/AllowTcpForwarding yes/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i 's/WAIT_OPTIONS="--wait 1 --wait-interval 20000"/WAIT_OPTIONS="--wait 1"/g' /etc/systemd/scripts/iptables
# sed -i "s/DHCP=yes/DHCP=no/g" /etc/systemd/network/99-dhcp-en.network
echo "" >> /etc/systemd/network/50-static-en.network
echo "" >> /etc/systemd/network/50-static-en.network
echo "[DHCP]" >> /etc/systemd/network/50-static-en.network
echo "UseDNS=false" >> /etc/systemd/network/50-static-en.network

tdnf -y update
tdnf -y install wget tar mc git rsync nfs-utils tcpdump netcat
# tdnf -y install docker docker-compose traceroute wireshark htop bindutils
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZAz6hJzLPHL6B+6jAkSg6JiuXT64++fjviRknBcUWMwhBSFTWPWHOXXrHBkBpoMZ3MOF3WKZTsAMZRgtNq7h1pk4D0m25Wb2i3bRUTKntao7tQ1SUETjnnBt6w311RBPUcm/YZsVoycZZeGTtH8Gn/6Wi/RviD2NmhgyRfoFaDDT+DKOp/TC2/J/kbWCPBlIAbGQn/dUUoPLA9eEQxuG6nowrx1Rv4/317LW3Fmg0cP7nHiKx3nXkrT9VwBV6w6uxmMRtiy6Nvg9OnzIG4gCo1B5nHWmsbOBfUPQKks6UAbcyaOF+lc65iWge8mpLOhl5M9javWjlI8s/g41H6MTRCkpch0mkEQuK3BOKkGR356x9BugpyMWVhqhSjcP47w6L+/qytJR/8eZwn6Y8NWNwLiVqAQkQYZCr6WHZAE6s5fs1XrHb3WgyI1fCRhfITSZYjRAl/uJIFkjQMeUtmPiW0sRyRJTgIy6EaFRKIjbTuYACHXK1fqvIcNjbu/MojXs= usname" > /root/.ssh/authorized_keys

wget -P /etc/profile.d/ https://raw.githubusercontent.com/plzapsys/inst/main/profile_show.sh
chmod +x /etc/profile.d/profile_show.sh

# install link from girhub
# curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon_haproxy.sh | sh

chage -I -1 -m 0 -M 99999 -E -1 root
# ----------- iptables ----------------------------------------
# Disable Firewall
# iptables --list
# systemctl stop iptables
# systemctl disable iptables
# systemctl restart systemd-networkd
# iptables --list
# Allow ICMP echo responses
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
# Allow port
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8404 -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

# systemctl restart iptables.service
# systemctl daemon-reload
# iptables --list
# iptables -L
# ---------------------------------------------------
# for HAProxy
tdnf install haproxy -y
openssl dhparam -out /etc/pki/tls/certs/dhparam.pem 2048 
mkdir /var/lib/haproxy
chmod 755 /var/lib/haproxy
systemctl enable haproxy
# haproxy -f /etc/haproxy/haproxy.cfg -c -V
# systemctl start haproxy
# systemctl status haproxy

# cerate /etc/sysctl.d/55-keepalived.conf
touch /etc/sysctl.d/55-keepalived.conf
chmod 644 /etc/sysctl.d/55-keepalived.conf
# add
echo "#Enable IPv4 Forwarding" >> /etc/sysctl.d/55-keepalived.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/55-keepalived.conf
echo "#Enable non-local IP bind" >> /etc/sysctl.d/55-keepalived.conf
echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.d/55-keepalived.conf

# -- restart 
history -c
shutdown -r now
