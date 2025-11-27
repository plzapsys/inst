#!/bin/bash

# Първо: Коригирайте URL адреса (липсва двойна наклонена черта //)
# Пример за dsw1:
# curl -s https://raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/1-setup-eth1-static-ip.sh | sudo bash -s -- d1node 192.168.30 eth1 20

# Пример за dsw2:
# curl -s https://raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/1-setup-eth1-static-ip.sh | sudo bash -s -- d2node 192.168.30 eth1 40

# Пример за dsw3:
# curl -s https://raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/1-setup-eth1-static-ip.sh | sudo bash -s -- d3node 192.168.30 eth1 30

# 1. Приемане на параметри
NODE_PREFIX=$1  # Първи параметър: d3node
BASE_NETWORK=$2 # Втори параметър: 192.168.30
INTERFACE_CLUSTER=$3 # Трети параметър: eth1
NODE_IP=$4 # IP да започва с 20 => 192.168.30.21 за първия нод

NETMASK="/24"

log_error() {
    echo -e "🚨 ГРЕШКА: $1" >&2
}

# --- 2. ПРОВЕРКА НА ПАРАМЕТРИТЕ ---
if [ "$#" -ne 4 ]; then
    log_error "Липсват задължителни параметри."
    echo "Очаквани параметри: 4 (подадени: $#)"
    echo "Употреба: $0 <NODE_PREFIX> <BASE_NETWORK> <INTERFACE_CLUSTER> <STARTING_OCTET>"
    echo "Пример: $0 d3node 192.168.30 eth1 20"
    exit 1
fi


echo "--- 3. Конфигуриране на статичен IP за $INTERFACE_CLUSTER ---"
echo "Използван префикс: $NODE_PREFIX"
echo "Използвана базова мрежа: $BASE_NETWORK"

HOSTNAME=$(hostname)
# Извличаме номера на възела, като премахваме дефинирания префикс
# Например: Ако HOSTNAME=d3node4, NODE_NUMBER ще бъде 4
NODE_NUMBER=$(echo "$HOSTNAME" | sed "s/$NODE_PREFIX//g")

if ! [[ "$NODE_NUMBER" =~ ^[1-6]$ ]]; then
    log_error "Невалиден hostname или номер на възела. Очаква се ${NODE_PREFIX}[1-6], получен: $HOSTNAME"
    exit 1
fi

# Изчисляване на последния октет: X + 20 (напр. 1 -> 21)
LAST_OCTET=$((NODE_NUMBER + NODE_IP))
NODE_IP_CLUSTER="${BASE_NETWORK}.${LAST_OCTET}${NETMASK}"

NETWORK_FILE="/etc/systemd/network/60-static-eth1.network"

echo "Генериране на мрежовия конфигурационен файл: $NETWORK_FILE ($NODE_IP_CLUSTER)"

cat <<EOF > $NETWORK_FILE
[Match]
Name=$INTERFACE_CLUSTER

[Network]
Address=$NODE_IP_CLUSTER

IPv6AcceptRA=no
LinkLocalAddressing=no
LLDP=false
EmitLLDP=false
MulticastDNS=no
EOF

# Задаваме права и прилагаме промените
chmod 644 /etc/systemd/network/*.network
sudo systemctl daemon-reload
sudo systemctl restart systemd-networkd
echo "$INTERFACE_CLUSTER е конфигуриран."
