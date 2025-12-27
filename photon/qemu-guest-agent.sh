#!/bin/bash
set -euo pipefail

echo "[*] Disabling cloud-init…"
for svc in cloud-init-local.service cloud-init.service cloud-config.service cloud-final.service; do
  if systemctl list-unit-files | grep -q "^${svc}"; then
    systemctl disable --now "$svc" || true
    systemctl mask "$svc" || true
  fi
done

echo "[*] Disabling VMware guestinfo / tools / ovf…"
for pattern in "vmware-tools" "vmtoolsd" "open-vm-tools" "ovfenv" "vmware"; do
  while read -r unit; do
    [ -z "$unit" ] && continue
    echo "  - masking $unit"
    systemctl disable --now "$unit" 2>/dev/null || true
    systemctl mask "$unit" 2>/dev/null || true
  done < <(systemctl list-unit-files | awk '{print $1}' | grep -i "$pattern" || true)
done

# Patch Photon bootloader configs
for cfg in /boot/photon.cfg /boot/linux-*.cfg; do
  if [ -f "$cfg" ]; then
    echo "  - Patching $cfg"
    cp "$cfg" "$cfg.bak.$(date +%s)"   # backup
    sed -i 's/audit=1/audit=0/g' "$cfg"
  fi
done

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

