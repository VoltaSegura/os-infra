#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
start_log teste-falha
unit=voltasegura-monitor.service
systemctl is-active --quiet "$unit"
before=$(systemctl show "$unit" -p MainPID --value)
restarts=$(systemctl show "$unit" -p NRestarts --value)
log "antes pid=$before reinicios=$restarts"
systemctl kill --kill-whom=main --signal=SIGKILL "$unit"
for attempt in {1..20}; do
  sleep 1
  after=$(systemctl show "$unit" -p MainPID --value)
  count=$(systemctl show "$unit" -p NRestarts --value)
  if systemctl is-active --quiet "$unit" && [[ "$after" != 0 && "$after" != "$before" ]] && ((count > restarts)); then
    log "recuperacao_confirmada pid=$after reinicios=$count"
    journalctl -u "$unit" -n 15 --no-pager
    exit 0
  fi
done
echo 'Falha: recuperacao nao comprovada no prazo.' >&2
exit 1
