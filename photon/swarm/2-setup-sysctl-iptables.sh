#!/bin/bash

# --- КОНФИГУРАЦИОННИ ПРОМЕНЛИВИ ---
INTERFACE_PUBLIC="eth0"
INTERFACE_CLUSTER="eth1" 

# Портове за IPTables
SWARM_PORT=2377       
DISCOVERY_PORT=7946   
OVERLAY_PORT=4789     
NFS_PORT=2049         
WEB_PORTS="80,443"    
ADMIN_PORTS="9010,8080" 

log_error() {
    echo -e "ГРЕШКА: $1" >&2
}

echo "--- 1. Конфигуриране на Sysctl (Keepalived / Docker Swarm) ---"
cat <<EOT > /etc/sysctl.d/90-keepalived-config.conf
net.ipv4.ip_nonlocal_bind=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=2
net.ipv4.conf.default.rp_filter=2
net.ipv4.conf.$INTERFACE_PUBLIC.rp_filter=2
EOT
sysctl -p /etc/sysctl.d/90-keepalived-config.conf >/dev/null
chmod 644 /etc/sysctl.d/90-keepalived-config.conf
echo "Критичните Sysctl настройки са приложени."


echo "--- 2. Конфигуриране на IPTables ---"

if [ -f /etc/systemd/scripts/ip4save ]; then
    iptables-restore < /etc/systemd/scripts/ip4save
else
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT 
fi

# Добавяне на Специфични Правила
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -i $INTERFACE_PUBLIC -p 112 -j ACCEPT
iptables -A INPUT -i $INTERFACE_CLUSTER -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j ACCEPT
iptables -A INPUT -i $INTERFACE_CLUSTER -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j ACCEPT
iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $WEB_PORTS,$NFS_PORT,$ADMIN_PORTS -j ACCEPT
iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j DROP
iptables -A INPUT -i $INTERFACE_PUBLIC -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j DROP

# ЗАПАЗВАНЕ И РЕСТАРТИРАНЕ
iptables-save > /etc/systemd/scripts/ip4save
sudo systemctl restart iptables
echo "IPTables правилата са приложени и запазени."
