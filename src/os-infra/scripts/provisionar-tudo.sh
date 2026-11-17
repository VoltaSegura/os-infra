#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
start_log provisionamento
bash "$ROOT/scripts/provisionar-infra.sh"
bash "$ROOT/scripts/provisionar-app.sh"
bash "$ROOT/scripts/instalar-monitoramento.sh"
systemctl is-active nginx voltasegura-monitor
curl --fail --silent --show-error http://127.0.0.1:8080/healthz
log 'concluido; navegador=http://IP_DA_VM:8080; modo=demo; integracao API pendente'
