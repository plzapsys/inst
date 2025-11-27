#!/bin/bash

# curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/2-setup-sysctl-iptables.sh | sh

# --- КОНФИГУРАЦИОННИ ПРОМЕНЛИВИ ---
INTERFACE_PUBLIC="eth0"
INTERFACE_CLUSTER="eth1" 

# Кластерни и Публични Портове
SWARM_PORT=2377       
DISCOVERY_PORT=7946   
OVERLAY_PORT=4789     
NFS_PORT=2049         
WEB_PORTS="80,443"    
ADMIN_PORTS="9010,8080" # Портове за администрация

# --- 1. ПЪЛНО ИЗЧИСТВАНЕ ---
echo "--- 1. Изчистване на текущи IPTables правила ---"
sudo iptables -F INPUT
sudo iptables -F FORWARD
sudo iptables -F OUTPUT
sudo iptables -X # Изтрива потребителски вериги

# --- 2. ЗАДАВАНЕ НА ПОЛИТИКИ И ОСНОВНИ ПРАВИЛА ---
echo "--- 2. Задаване на DROP политика и основни ACCEPT правила ---"

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

# --- 3. ПРАВИЛА ЗА КЛАСТЕРНА КОМУНИКАЦИЯ (ETH1) ---
echo "--- 3. ACCEPT правила за $INTERFACE_CLUSTER (Swarm) ---"

# Swarm TCP (2377, 7946)
sudo iptables -A INPUT -i $INTERFACE_CLUSTER -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j ACCEPT
# Swarm UDP (7946, 4789)
sudo iptables -A INPUT -i $INTERFACE_CLUSTER -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j ACCEPT

# --- 4. ПРАВИЛА ЗА ПУБЛИЧЕН ИЛИ АДМИН ДОСТЪП (ETH0) ---
echo "--- 4. ACCEPT правила за $INTERFACE_PUBLIC (Web/Admin) ---"

# VRRP (Keepalived - Протокол 112)
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p 112 -j ACCEPT

# Web, NFS и Admin Портове (80, 443, 2049, 9010, 8080)
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $WEB_PORTS,$NFS_PORT,$ADMIN_PORTS -j ACCEPT

# --- 5. ЕКСПЛИЦИТНО БЛОКИРАНЕ НА SWARM ТРАФИК ПРЕЗ ETH0 ---
echo "--- 5. DROP правила за Swarm трафик през $INTERFACE_PUBLIC ---"

# Блокираме Swarm/Discovery TCP през публичния интерфейс
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p tcp -m multiport --dports $SWARM_PORT,$DISCOVERY_PORT -j DROP
# Блокираме Swarm/Overlay UDP през публичния интерфейс
sudo iptables -A INPUT -i $INTERFACE_PUBLIC -p udp -m multiport --dports $DISCOVERY_PORT,$OVERLAY_PORT -j DROP

# --- 6. ЗАПАЗВАНЕ И РЕСТАРТИРАНЕ ---
echo "--- 6. Запазване и рестартиране на IPTables ---"

# Уверете се, че директорията съществува
sudo mkdir -p /etc/systemd/scripts/
sudo iptables-save | sudo tee /etc/systemd/scripts/ip4save > /dev/null

sudo systemctl daemon-reload
sudo systemctl restart iptables
echo "✅ IPTables конфигурацията е приложена и запазена."
