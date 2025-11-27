#!/bin/bash

# curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/2-setup-sysctl-iptables.sh | sh

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
    echo -e "🚨 ГРЕШКА: $1" >&2
}

# --- 1. КОНФИГУРИРАНЕ НА SYSCTL ---

echo "--- 1. Конфигуриране на Sysctl (Keepalived / Docker Swarm) ---"

# Използваме sudo tee за сигурно създаване на файл с root права
cat <<EOT | sudo tee /etc/sysctl.d/90-keepalived-config.conf > /dev/null
net.ipv4.ip_nonlocal_bind=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=2
net.ipv4.conf.default.rp_filter=2
net.ipv4.conf.$INTERFACE_PUBLIC.rp_filter=2
EOT

sudo sysctl -p /etc/sysctl.d/90-keepalived-config.conf >/dev/null
# chmod вече не е необходим, тъй като tee създава файла с права 644 по подразбиране
echo "✅ Критичните Sysctl настройки са приложени."


# --- 2. КОНФИГУРИРАНЕ НА IPTABLES ---

echo "--- 2. Конфигуриране на IPTables ---"

if [ -f /etc/systemd/scripts/ip4save ]; then
    # Използваме sudo за възстановяване на правилата
    sudo iptables-restore < /etc/systemd/scripts/ip4save
else
    # Ако няма запазен файл, задаваме DROP политика
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT ACCEPT 
fi

# Добавяне на Специфични Правила (използваме sudo за всяко добавяне)
# Това гарантира, че правилата се прилагат коректно
sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j ACCEPT

# VRRP (Keepalived) - САМО през публичния интерфейс
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p 112 -j ACCEPT

# Docker Swarm - САМО през кластерния интерфейс
sudo iptables -A INPUT -i $INTERFACE_CLUSTER -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j ACCEPT
sudo iptables -A INPUT -i $INTERFACE_CLUSTER -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j ACCEPT

# WEB/ADMIN Трафик - САМО през публичния интерфейс
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $WEB_PORTS,$NFS_PORT,$ADMIN_PORTS -j ACCEPT

# Блокиране на Swarm трафика ПРЕЗ публичния интерфейс (eth0)
# Тези DROP правила сега са ефективни, защото по-ранните ACCEPT правила са ограничени до eth1.
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j DROP
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j DROP

# ЗАПАЗВАНЕ И РЕСТАРТИРАНЕ
# Използваме sudo iptables-save за запазване на правилата с root права
sudo iptables-save > /etc/systemd/scripts/ip4save
sudo systemctl restart iptables
echo "✅ IPTables правилата са приложени и запазени."
