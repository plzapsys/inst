

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
dnf install -y wget which curl
dnf update -y ca-certificates
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
# dnf clean all
dnf update -y
dnf install -y 'dnf-command(config-manager)'
dnf install -y dnf-plugins-core
# dnf config-manager --set-enabled powertools
# dnf install -y dnf-utils iscsi-initiator-utils
dnf install -y iftop htop atop lsof bzip2 bind-utils mtr 
dnf install -y mc nano vim net-tools open-vm-tools zip unzip pv git rsync sshpass 
dnf install -y nfs-utils
systemctl disable firewalld
# openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout /etc/pki/tls/certs/zapsys-key.pem -out /etc/pki/tls/certs/zapsys-cert.pem

wget -P /etc/profile.d/ https://raw.githubusercontent.com/plzapsys/inst/main/profile_show.sh
chmod +x /etc/profile.d/profile_show.sh
timedatectl set-timezone Europe/Sofia
# echo "blacklist i2c_piix4" > /etc/modprobe.d/blacklist.conf
# echo "" >> /root/.bashrc
# echo "export VISUAL=nano;" >> /root/.bashrc
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=65536/g' /etc/systemd/system.conf

touch /root/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZAz6hJzLPHL6B+6jAkSg6JiuXT64++fjviRknBcUWMwhBSFTWPWHOXXrHBkBpoMZ3MOF3WKZTsAMZRgtNq7h1pk4D0m25Wb2i3bRUTKntao7tQ1SUETjnnBt6w311RBPUcm/YZsVoycZZeGTtH8Gn/6Wi/RviD2NmhgyRfoFaDDT+DKOp/TC2/J/kbWCPBlIAbGQn/dUUoPLA9eEQxuG6nowrx1Rv4/317LW3Fmg0cP7nHiKx3nXkrT9VwBV6w6uxmMRtiy6Nvg9OnzIG4gCo1B5nHWmsbOBfUPQKks6UAbcyaOF+lc65iWge8mpLOhl5M9javWjlI8s/g41H6MTRCkpch0mkEQuK3BOKkGR356x9BugpyMWVhqhSjcP47w6L+/qytJR/8eZwn6Y8NWNwLiVqAQkQYZCr6WHZAE6s5fs1XrHb3WgyI1fCRhfITSZYjRAl/uJIFkjQMeUtmPiW0sRyRJTgIy6EaFRKIjbTuYACHXK1fqvIcNjbu/MojXs= usname" > /root/.ssh/authorized_keys


# cp /usr/share/mc/syntax/sh.syntax /usr/share/mc/syntax/unknown.syntax
# yum install chrony
# systemctl start chronyd
# systemctl enable chronyd
# systemctl status chronyd

# timedatectl 

# history 
# history | grep yum

# clear all history CL

history -c

shutdown -r now
