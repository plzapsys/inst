#!/bin/bash

# curl https:/raw.githubusercontent.com/plzapsys/inst/main/photon/swarm/3-disable-offloading.sh | sh

log_error() {
    echo -e "ГРЕШКА: $1" >&2
}

echo "--- 1. Деактивиране на TX Checksum Offloading (За Docker Overlay) ---"

ETHTOOL="ethtool"

if [ ! -x "$ETHTOOL" ]; then
    echo "ethtool не е намерен. Опит за инсталиране..."
    tdnf install ethtool -y
    if [ $? -ne 0 ]; then
        log_error "Неуспешна инсталация на ethtool."
        exit 1
    fi
fi

INTERFACES=$(ls /sys/class/net | grep '^eth')
OFFLOAD_CMDS=""
for IFACE in $INTERFACES; do
    OFFLOAD_CMDS+="$ETHTOOL -K $IFACE tx off; "
done

cat <<EOF | sudo tee /etc/systemd/system/disable-offloading.service > /dev/null
[Unit]
Description=Disable TX checksum offloading on all eth* interfaces
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '$OFFLOAD_CMDS'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "--- 2. Прилагане на Systemd Промените ---"
sudo systemctl daemon-reload
sudo systemctl enable disable-offloading.service
sudo systemctl start disable-offloading.service
echo "TX offloading е деактивиран и услугата е активирана."
