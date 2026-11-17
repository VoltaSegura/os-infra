#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
start_log infra
source /etc/os-release
[[ "$ID" == ubuntu ]] || { echo 'Este provisionador requer Ubuntu Server.' >&2; exit 1; }
[[ "${APLICAR_REDE:-}" == SIM ]] || { echo 'Execute no console da VM com APLICAR_REDE=SIM e INTERFACE definida. Consulte o guia.' >&2; exit 1; }
: "${INTERFACE:?Informe a interface Ethernet, obtida com ip -br link}"
[[ "$INTERFACE" =~ ^[a-zA-Z0-9_-]+$ && "$INTERFACE" != lo ]]
ip link show dev "$INTERFACE" >/dev/null
[[ -d /etc/netplan ]]
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx curl git sysstat python3 netplan.io
hostnamectl set-hostname voltasegura-os
if ! grep -qE '^127\.0\.1\.1[[:space:]]+.*voltasegura-os' /etc/hosts; then
  printf '\n127.0.1.1 voltasegura-os\n' >> /etc/hosts
fi
BACKUP="/var/backups/voltasegura/netplan-$(date +%Y%m%d-%H%M%S)"
install -d -m 0700 "$BACKUP"
cp -a /etc/netplan/. "$BACKUP/"
log "backup_rede=$BACKUP"
# Cenário suportado: VM Ubuntu Server nova, uma interface Ethernet com ID Netplan igual ao nome.
# O arquivo posterior sobrescreve as propriedades desse mesmo ID sem remover os outros arquivos.
cat > /etc/netplan/99-voltasegura.yaml <<EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
EOF
chmod 0600 /etc/netplan/99-voltasegura.yaml
netplan generate
netplan apply
for attempt in {1..15}; do
  if getent ahostsv4 github.com >/dev/null; then break; fi
  sleep 2
done
getent ahostsv4 github.com
ip -br address show "$INTERFACE"
ip route
hostnamectl
install -d -m 0755 /var/log/journal /etc/systemd/journald.conf.d
printf '[Journal]\nStorage=persistent\nSystemMaxUse=100M\n' > /etc/systemd/journald.conf.d/voltasegura.conf
systemctl restart systemd-journald
log 'infraestrutura concluida; IP via DHCP; DNS explicito 1.1.1.1 e 8.8.8.8'
