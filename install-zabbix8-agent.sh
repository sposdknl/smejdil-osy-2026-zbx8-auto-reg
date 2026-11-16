#!/bin/sh
set -eu

# Zachováme ostatní nastavení a při opakování nevytváříme duplicity.
touch /etc/make.conf
sed -i '' -E '/^[[:space:]]*(BATCH|ALLOW_UNSUPPORTED_SYSTEM)[[:space:]]*[+?:!]?=/d' /etc/make.conf
cat >> /etc/make.conf <<'EOF'
BATCH="yes"
ALLOW_UNSUPPORTED_SYSTEM="YES"
EOF

cd /usr/ports/net-mgmt/zabbix8-agent/
# Již nainstalovaný port při opakovaném provisioningu znovu neinstalujeme.
if ! pkg info -e zabbix8-agent; then
  # Starší agent používá stejné soubory a službu jako verze 8.
  if pkg info -e zabbix7-agent; then
    service zabbix_agentd onestop || true
    pkg delete -y zabbix7-agent
  fi
  # Balíček vytvoříme před instalací, dokud jsou dostupná metadata stagingu.
  # Jednotlivé kroky spouštíme postupně a čistíme až po úspěšné instalaci.
  make package
  make install
  make clean
fi

version=$(pkg query '%v' zabbix8-agent)
case "$version" in
  8.*) ;;
  *) echo "Neočekávaná verze zabbix8-agent: $version" >&2; exit 1 ;;
esac

/usr/local/sbin/zabbix_agentd -V
