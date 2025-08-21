

timedatectl set-timezone Europe/Sofia

sed -i "s/AllowTcpForwarding no/AllowTcpForwarding yes/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config
# systemctl restart sshd

# sed -i 's/#DefaultLimitNOFILE=1024:524288/DefaultLimitNOFILE=65000/g' /etc/systemd/system.conf
# sed -i 's/#DefaultLimitNPROC=/DefaultLimitNPROC=65000/g' /etc/systemd/system.conf
# sed -i 's/#DefaultTasksMax=15%/DefaultTasksMax=75%/g' /etc/systemd/system.conf

tdnf -y update
tdnf -y install docker docker-compose wget htop tar mc git rsync nfs-utils 
# tdnf -y install traceroute wireshark  bindutils


systemctl disable iptables
systemctl stop iptables

systemctl enable docker
systemctl start docker

echo "blacklist piix4_smbus" > /etc/modprobe.d/blacklist.conf
echo "blacklist i2c_piix4" > /etc/modprobe.d/blacklist.conf

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZAz6hJzLPHL6B+6jAkSg6JiuXT64++fjviRknBcUWMwhBSFTWPWHOXXrHBkBpoMZ3MOF3WKZTsAMZRgtNq7h1pk4D0m25Wb2i3bRUTKntao7tQ1SUETjnnBt6w311RBPUcm/YZsVoycZZeGTtH8Gn/6Wi/RviD2NmhgyRfoFaDDT+DKOp/TC2/J/kbWCPBlIAbGQn/dUUoPLA9eEQxuG6nowrx1Rv4/317LW3Fmg0cP7nHiKx3nXkrT9VwBV6w6uxmMRtiy6Nvg9OnzIG4gCo1B5nHWmsbOBfUPQKks6UAbcyaOF+lc65iWge8mpLOhl5M9javWjlI8s/g41H6MTRCkpch0mkEQuK3BOKkGR356x9BugpyMWVhqhSjcP47w6L+/qytJR/8eZwn6Y8NWNwLiVqAQkQYZCr6WHZAE6s5fs1XrHb3WgyI1fCRhfITSZYjRAl/uJIFkjQMeUtmPiW0sRyRJTgIy6EaFRKIjbTuYACHXK1fqvIcNjbu/MojXs= usname" > /root/.ssh/authorized_keys

wget -P /etc/profile.d/ https://raw.githubusercontent.com/plzapsys/inst/main/profile_show.sh
chmod +x /etc/profile.d/profile_show.sh

chage -I -1 -m 0 -M 99999 -E -1 root
# --------- Platform -------------------------------------------------------------------------------------------
# tdnf -y install openjdk17
# mkdir /mnt/general
# mkdir /mnt/documents
# mkdir /mnt/sftp

# echo "192.168.53.70:/PNFS/general      /mnt/general               nfs4     defaults        0 0" >> /etc/fstab
# echo "192.168.53.70:/PNFS/documents    /mnt/documents             nfs4     defaults        0 0" >> /etc/fstab
# echo "192.168.53.70:/PNFS/sftp         /mnt/sftp                  nfs4     defaults        0 0" >> /etc/fstab
# ------------------------------------------------------------------------------------------------------------------
history -c
shutdown -r now

# find /lib/modules/$(uname -r) -type f -name '*.ko*'  |  grep iptable 
# sudo netstat -tulpn | grep LISTEN
# systemctl status systemd-modules-load

#  if use iptablse
# /etc/systemd/scripts/ip4save
# add to file -> ip4save

    # -A INPUT -i lo -j ACCEPT
    # -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    # -A INPUT -s 0.0.0.0/28 -p tcp -m tcp --dport 22 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 8000 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 8280 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 5222 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 5347 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 5280 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
    # -A INPUT -p tcp -m tcp --dport 8443 -j ACCEPT
    # -A INPUT -p udp -m udp --dport 1000 -j ACCEPT

#  -----------------------------------------------------------
# OVA template
# Create file
# vi 10-static-en.network
# ----------------------------------------------
# [Match]
# Name=eth0

# [Network]
# DHCP=no
# Address=192.168.1.10/24
# Gateway=192.168.1.1
# Domains=domain.local
# DNS=192.168.1.71

# chmod o+r /etc/systemd/network/10-static-en.network
#  -----------------------------------------------------------------------------------------------

# https://www.johnborhek.com/operating-systems/linux/photon-os/setting-static-ip-photon-os/
# https://jreypo.io/2016/02/08/network-configuration-in-photon-os/
# !!! https://vmguru.com/2018/10/getting-started-with-photon-os/

# https://vmware.github.io/photon/assets/files/html/1.0-2.0/Running-Photon-OS-on-vSphere.html
