#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C
INTERVAL=${INTERVAL:-10}
CPU_LIMIT=${CPU_LIMIT:-80}
MEMORY_LIMIT=${MEMORY_LIMIT:-80}
DISK_LIMIT=${DISK_LIMIT:-85}
[[ "$INTERVAL" =~ ^[0-9]+$ ]] && ((INTERVAL >= 2 && INTERVAL <= 3600))
for limit in "$CPU_LIMIT" "$MEMORY_LIMIT" "$DISK_LIMIT"; do
  [[ "$limit" =~ ^[0-9]+$ ]] && ((limit >= 0 && limit <= 100))
done
sample_cpu() {
  awk '/^cpu / {idle=$5+$6; total=0; for(i=2;i<=NF && i<=9;i++)total+=$i; print total,idle;exit}' /proc/stat
}
emit() { printf '%s %s\n' "$(date -Is)" "$*"; }
emit 'INFO monitor iniciado'
read -r previous_total previous_idle < <(sample_cpu)
while true; do
  sleep "$INTERVAL"
  read -r current_total current_idle < <(sample_cpu)
  cpu=$(awk -v t="$((current_total-previous_total))" -v i="$((current_idle-previous_idle))" 'BEGIN{if(t<=0)exit 1; printf "%.1f",100*(t-i)/t}')
  memory=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END{if(t<=0)exit 1; printf "%.1f",100*(t-a)/t}' /proc/meminfo)
  disk=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5);print $5}')
  [[ "$disk" =~ ^[0-9]+$ ]]
  emit "INFO cpu=$cpu memoria=$memory disco=$disk filesystem=/"
  for entry in "cpu:$cpu:$CPU_LIMIT" "memoria:$memory:$MEMORY_LIMIT" "disco:$disk:$DISK_LIMIT"; do
    IFS=: read -r resource value threshold <<< "$entry"
    if awk -v v="$value" -v l="$threshold" 'BEGIN{exit !(v>l)}'; then
      emit "ALERTA recurso=$resource uso=$value limite=$threshold"
    fi
  done
  previous_total=$current_total; previous_idle=$current_idle
done
