#!/bin/sh
set -eu

# Na novém FreeBSD boxu nemusí být správce balíčků ještě zavedený.
if ! pkg -N >/dev/null 2>&1; then
  env ASSUME_ALWAYS_YES=yes pkg bootstrap -f
fi
pkg update
pkg install -y zabbix7-agent

version=$(pkg query '%v' zabbix7-agent)
case "$version" in
  7.0.*) ;;
  *) echo "Neočekávaná verze zabbix7-agent: $version" >&2; exit 1 ;;
esac

/usr/local/sbin/zabbix_agentd -V
