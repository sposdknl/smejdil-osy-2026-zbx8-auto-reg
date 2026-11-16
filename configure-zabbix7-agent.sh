#!/bin/sh
set -eu

config=/usr/local/etc/zabbix7/zabbix_agentd.conf
sample=${config}.sample
name_file=/var/db/zabbix7-agent/spos-hostname

install -d -m 0755 /var/db/zabbix7-agent
if [ ! -s "$name_file" ]; then
  id=$(uuidgen | tr -d '-' | cut -c1-12 | tr '[:upper:]' '[:lower:]')
  printf 'spos-freebsd-%s\n' "$id" > "$name_file"
  chmod 0644 "$name_file"
fi
hostname=$(cat "$name_file")
if ! printf '%s\n' "$hostname" | grep -Eq '^spos-freebsd-[[:xdigit:]]{12}$'; then
  echo "Neplatný uložený název hosta: $hostname" >&2
  exit 1
fi

if [ ! -f "$config" ]; then
  cp "$sample" "$config"
fi
if [ ! -f "${config}.orig" ]; then
  cp -p "$config" "${config}.orig"
fi

# Při opakovaném provisioningu nenecháme v konfiguraci duplicitní parametry.
sed -i '' -E '/^[[:space:]#]*(Hostname|Server|ServerActive|HostMetadata)=/d' "$config"
cat >> "$config" <<EOF2

# Nastavení pro úlohu OSY
Hostname=$hostname
Server=enceladus.pfsense.cz
ServerActive=enceladus.pfsense.cz
HostMetadata=FBSD
EOF2

sysrc zabbix_agentd_enable=YES
if service zabbix_agentd onestatus >/dev/null 2>&1; then
  service zabbix_agentd restart
else
  service zabbix_agentd start
fi
service zabbix_agentd status
printf 'Zabbix agent běží jako %s\n' "$hostname"
