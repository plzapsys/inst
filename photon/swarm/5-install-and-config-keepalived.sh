#!/bin/bash


# dsw1
#  curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/5-install-and-config-keepalived.sh 192.168.23.21 192.168.23.22 192.168.23.33 192.168.23.20/24 20 | sh

# dsw2
#  curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/5-install-and-config-keepalived.sh 192.168.43.41 192.168.43.42 192.168.43.43 192.168.43.40/24 40 | sh

# dsw3
#  curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/5-install-and-config-keepalived.sh 192.168.33.31 192.168.33.32 192.168.33.33 192.168.33.30/24 30 | sh


# Задължителни параметри
NODE1_IP=$1  # MASTER (Приоритет 150)
NODE2_IP=$2  # BACKUP (Приоритет 100)
NODE3_IP=$3  # BACKUP (Приоритет 50)
WEB_VIP=$4   # Виртуалният IP адрес с маска (напр. 192.168.33.20/24)
VRID=$5      # Virtual Router ID (1-255)

# Проверка дали всички 5 параметъра са подадени
if [ "$#" -ne 5 ]; then
    echo -e "ГРЕШКА: Липсват задължителни параметри."
    echo "Употреба: $0 <NODE1_IP> <NODE2_IP> <NODE3_IP> <WEB_VIP> <VRID>"
    echo "Пример: $0 192.168.33.21 192.168.33.22 192.168.33.23 192.168.33.20/24 233"
    exit 1
fi

WEB_VIP_IP="${WEB_VIP%/*}" 
INTERFACE="eth0"
AUTH_PASS="secret80" 
FALLBACK_PRIORITY="50" 
WEIGHT="60" 

log_error() {
    echo -e "🚨 ГРЕШКА: $1" >&2
}

generate_vrrp_instance() {
    local STATE=$1
    local PRIORITY=$2
    cat <<EOM
vrrp_instance VI_WEB {
    state $STATE
    interface $INTERFACE
    virtual_router_id $VRID
    priority $PRIORITY
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass $AUTH_PASS
    }
    virtual_ipaddress {
        $WEB_VIP
    }
    track_script {
        chk_obsnet
        chk_proxy
    }
    notify_master "/usr/bin/arping -c 3 -A -I $INTERFACE $WEB_VIP_IP"
    notify_backup "/usr/bin/arping -c 3 -U -I $INTERFACE $WEB_VIP_IP"
}
EOM
}

echo "--- 3. Проверки и Определяне на Ролята ---"

if ! command -v docker &> /dev/null; then
    log_error "Docker не е намерен. Keepalived скриптовете няма да работят."
    exit 1
fi

# Проверка за наличието на Docker мрежите
for NET_NAME in obs-net proxy; do
    echo "Проверявам за наличието на Docker мрежа '$NET_NAME'..."
    if ! docker network inspect "$NET_NAME" >/dev/null 2>&1; then
        log_error "Критична грешка: Docker overlay мрежата '$NET_NAME' НЕ Е налична. Прекратяване."
        exit 1
    else
        echo "Docker мрежата '$NET_NAME' е налична."
    fi
done

# Определяне на локалния IP адрес на eth0
LOCAL_IP=$(ip -4 addr show $INTERFACE 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)

if [ -z "$LOCAL_IP" ]; then
    log_error "Не може да се определи локалният IP адрес на $INTERFACE. Прекратяване."
    exit 1
fi

# Определяне на ролята (MASTER, BACKUP с приоритети)
if [[ "$LOCAL_IP" == "$NODE1_IP" ]]; then
    ROLE_STATE="MASTER"
    ROLE_PRIORITY=150
elif [[ "$LOCAL_IP" == "$NODE2_IP" ]]; then
    ROLE_STATE="BACKUP"
    ROLE_PRIORITY=100
else
    # NODE3 и всички останали възли използват най-ниския приоритет
    ROLE_STATE="BACKUP"
    ROLE_PRIORITY=$FALLBACK_PRIORITY
fi

echo "Конфигурация на възел ($LOCAL_IP): Роля $ROLE_STATE (Приоритет $ROLE_PRIORITY)"

echo "--- 4. Инсталация и Keepalived ---"
tdnf install -y keepalived
if [ $? -ne 0 ]; then
    log_error "Инсталацията на keepalived се провали."
    exit 1
fi

# Генериране на конфигурацията
cat <<EOF > /etc/keepalived/keepalived.conf

global_defs {
    script_user root
    enable_script_security
}

vrrp_script chk_obsnet {
    script "/bin/bash -c 'docker network inspect obs-net >/dev/null 2>&1'"
    interval 5
    weight $WEIGHT
}

vrrp_script chk_proxy {
    script "/bin/bash -c 'docker network inspect proxy >/dev/null 2>&1'"
    interval 5
    weight $WEIGHT
}

$(generate_vrrp_instance "$ROLE_STATE" "$ROLE_PRIORITY")
EOF

chmod 600 /etc/keepalived/keepalived.conf

systemctl enable keepalived
systemctl restart keepalived
echo "Конфигурацията завърши успешно."
echo "--- Състояние на Keepalived ---"
systemctl status keepalived --no-pager
