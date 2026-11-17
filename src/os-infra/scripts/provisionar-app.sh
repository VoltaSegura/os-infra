#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
start_log app
command -v nginx >/dev/null
install -d -m 0755 /var/www/voltasegura
install -m 0644 "$ROOT"/web/* /var/www/voltasegura/
# Formato sem IP, query string, corpo, origem ou destino. Error logs do servidor podem
# conter metadados de conexao em falhas: revisar e anonimizar antes de compartilhar.
printf 'log_format vs_privacy '\''$time_iso8601 method=$request_method status=$status bytes=$body_bytes_sent duration=$request_time'\'';\n' > /etc/nginx/conf.d/00-vs-log.conf
install -m 0644 "$ROOT/nginx/voltasegura.conf" /etc/nginx/sites-available/voltasegura
ln -sfn /etc/nginx/sites-available/voltasegura /etc/nginx/sites-enabled/voltasegura
nginx -t
systemctl enable --now nginx
systemctl reload nginx
curl --fail --silent --show-error http://127.0.0.1:8080/healthz
log 'portal instalado em /var/www/voltasegura; porta=8080; modo=demo; backend ainda nao conectado'
