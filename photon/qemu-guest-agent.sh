
tdnf install -y wget
wget https://raw.githubusercontent.com/plzapsys/inst/main/photon/qemu-guest-agent-8.1.0-1.ph5.x86_64.rpm
rpm -ivh --nosignature qemu-guest-agent-8.1.0-1.ph5.x86_64.rpm

#  curl -s https://raw.githubusercontent.com/plzapsys/inst/main/photon/qemu-guest-agent.sh | sudo bash

# https://github.com/snapshotleisure/photon-os-qemu-guest-agent # source
cat <<EOT | sudo tee /etc/systemd/system/qemu-guest-agent.service > /dev/null
[Unit]
Description=QEMU Guest Agent
BindsTo=dev-virtio\x2dports-org.qemu.guest_agent.0.device
After=dev-virtio\x2dports-org.qemu.guest_agent.0.device

[Service]
ExecStart=-/usr/bin/qemu-ga
Restart=always
RestartSec=0

[Install]
WantedBy=multi-user.target
EOT

systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent

