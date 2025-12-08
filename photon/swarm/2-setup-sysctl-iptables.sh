#!/bin/bash

# curl -s https://raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/2-setup-sysctl-iptables.sh | sudo bash

# Скрипт 2/4: Конфигуриране на системните параметри (Sysctl) и защитната стена (IPTables).

# --- КОНФИГУРАЦИОННИ ПРОМЕНЛИВИ ---
INTERFACE_PUBLIC="eth0"
INTERFACE_CLUSTER="eth1" 

# Кластерни и Публични Портове
SWARM_PORT=2377       
DISCOVERY_PORT=7946   
OVERLAY_PORT=4789     
NFS_PORT=2049         
WEB_PORTS="80,443"    
ADMIN_PORTS="9010,8080,6379,26379" 

# --- 1. КОНФИГУРИРАНЕ НА SYSCTL (Keepalived / Docker Swarm) ---
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
echo "✅ Критичните Sysctl настройки са приложени."

# -------------------------------------------------------------------

# --- 2. ПЪЛНО ИЗЧИСТВАНЕ НА IPTABLES ---
echo "--- 2. Изчистване на текущи IPTables правила ---"
sudo iptables -F INPUT
sudo iptables -F FORWARD
sudo iptables -F OUTPUT
sudo iptables -X # Изтрива потребителски вериги (нормално е да има грешка за DOCKER)

# --- 3. ЗАДАВАНЕ НА ПОЛИТИКИ И ОСНОВНИ ACCEPT ПРАВИЛА ---
echo "--- 3. Задаване на DROP политика и основни ACCEPT правила ---"

# Политики
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT 

# Основни правила за работа на системата
sudo iptables -A INPUT -i lo -j ACCEPT # Loopback
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j ACCEPT
sudo iptables -A INPUT -p icmp -j ACCEPT

# Разрешаваме SSH (TCP 22) за администрация
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# --- 4. ПРАВИЛА ЗА КЛАСТЕРНА КОМУНИКАЦИЯ (ETH1) ---
echo "--- 4. ACCEPT правила за $INTERFACE_CLUSTER (Swarm) ---"

# Swarm TCP (2377, 7946)
sudo iptables -A INPUT -i $INTERFACE_CLUSTER -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j ACCEPT
# Swarm UDP (7946, 4789)
sudo iptables -A INPUT -i $INTERFACE_CLUSTER -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j ACCEPT

# --- 5. ПРАВИЛА ЗА ПУБЛИЧЕН ИЛИ АДМИН ДОСТЪП (ETH0) ---
echo "--- 5. ACCEPT правила за $INTERFACE_PUBLIC (Web/Admin) ---"

# VRRP (Keepalived - Протокол 112)
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p 112 -j ACCEPT

# Web, NFS и Admin Портове (80, 443, 2049, 9010, 8080)
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $WEB_PORTS,$NFS_PORT,$ADMIN_PORTS -j ACCEPT

# --- 6. ЕКСПЛИЦИТНО БЛОКИРАНЕ НА SWARM ТРАФИК ПРЕЗ ETH0 ---
echo "--- 6. DROP правила за Swarm трафик през $INTERFACE_PUBLIC ---"

# Блокираме Swarm/Discovery TCP през публичния интерфейс
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j DROP
# Блокираме Swarm/Overlay UDP през публичния интерфейс
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j DROP

# --- 7. ЗАПАЗВАНЕ И РЕСТАРТИРАНЕ ---
echo "--- 7. Запазване и рестартиране на IPTables ---"

# Уверете се, че директорията съществува
sudo mkdir -p /etc/systemd/scripts/
sudo iptables-save | sudo tee /etc/systemd/scripts/ip4save > /dev/null

sudo systemctl daemon-reload
sudo systemctl restart iptables
echo "✅ IPTables конфигурацията е приложена и запазена."
