

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
tdnf -y install docker docker-compose wget htop tar mc git rsync nfs-utils tcpdump netcat cronie chrony
# tdnf -y install traceroute wireshark  bindutils
systemctl enable --now chronyd

# install link from girhub
# curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/photon_docker.sh | sh

systemctl disable iptables
systemctl stop iptables

systemctl enable docker
systemctl start docker

systemctl enable crond
systemctl start crond

mkdir /mnt/container
chmod 755 /mnt/container

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZAz6hJzLPHL6B+6jAkSg6JiuXT64++fjviRknBcUWMwhBSFTWPWHOXXrHBkBpoMZ3MOF3WKZTsAMZRgtNq7h1pk4D0m25Wb2i3bRUTKntao7tQ1SUETjnnBt6w311RBPUcm/YZsVoycZZeGTtH8Gn/6Wi/RviD2NmhgyRfoFaDDT+DKOp/TC2/J/kbWCPBlIAbGQn/dUUoPLA9eEQxuG6nowrx1Rv4/317LW3Fmg0cP7nHiKx3nXkrT9VwBV6w6uxmMRtiy6Nvg9OnzIG4gCo1B5nHWmsbOBfUPQKks6UAbcyaOF+lc65iWge8mpLOhl5M9javWjlI8s/g41H6MTRCkpch0mkEQuK3BOKkGR356x9BugpyMWVhqhSjcP47w6L+/qytJR/8eZwn6Y8NWNwLiVqAQkQYZCr6WHZAE6s5fs1XrHb3WgyI1fCRhfITSZYjRAl/uJIFkjQMeUtmPiW0sRyRJTgIy6EaFRKIjbTuYACHXK1fqvIcNjbu/MojXs= usname" > /root/.ssh/authorized_keys

wget -P /etc/profile.d/ https://raw.githubusercontent.com/plzapsys/inst/main/profile_show.sh
chmod +x /etc/profile.d/profile_show.sh

chage -I -1 -m 0 -M 99999 -E -1 root

history -c
shutdown -r now

