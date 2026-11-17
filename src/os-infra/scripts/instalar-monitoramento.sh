#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
start_log instalar-monitoramento
install -d -m 0755 /etc/voltasegura
if [[ ! -e /etc/voltasegura/monitor.env ]]; then
  install -m 0644 "$ROOT/config/monitor.env.example" /etc/voltasegura/monitor.env
fi
install -m 0755 "$ROOT/scripts/monitorar.sh" /usr/local/bin/voltasegura-monitor.sh
install -m 0644 "$ROOT/systemd/voltasegura-monitor.service" /etc/systemd/system/voltasegura-monitor.service
systemctl daemon-reload
systemctl enable --now voltasegura-monitor.service
systemctl restart voltasegura-monitor.service
systemctl is-active --quiet voltasegura-monitor.service
log 'monitor instalado; logs em journalctl -u voltasegura-monitor'
