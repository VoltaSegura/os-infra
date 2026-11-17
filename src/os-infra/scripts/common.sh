#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
require_root() { [[ $EUID -eq 0 ]] || { echo 'Execute com sudo.' >&2; exit 1; }; }
start_log() {
  require_root
  install -d -m 0750 /var/log/voltasegura
  local logfile="/var/log/voltasegura/${1}.log"
  touch "$logfile"; chmod 0640 "$logfile"
  exec > >(tee -a "$logfile") 2>&1
  trap 'rc=$?; printf "%s ERROR script=%s linha=%s codigo=%s\n" "$(date -Is)" "$0" "$LINENO" "$rc"; exit "$rc"' ERR
  printf '%s INFO inicio script=%s operador=%s\n' "$(date -Is)" "$0" "${SUDO_USER:-root}"
}
log() { printf '%s INFO %s\n' "$(date -Is)" "$*"; }
