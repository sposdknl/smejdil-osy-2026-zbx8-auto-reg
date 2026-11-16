# OSY: automatická registrace FreeBSD do Zabbixu

![Ilustrace FreeBSD serveru a monitoringu](Images/freebsd-zabbix-hero.png)

Tato varianta zadání používá box [bento/freebsd-14](https://portal.cloud.hashicorp.com/vagrant/discover/bento/freebsd-14) a klasického agenta **Zabbix 7.0** z balíčku `zabbix7-agent`. Vagrant spustí instalační a konfigurační skript automaticky. Agent se připojuje k `enceladus.pfsense.cz` a pro automatickou registraci odesílá `HostMetadata=FBSD`, aby se použilo pravidlo pro FreeBSD.

## Spuštění

```sh
vagrant validate
vagrant up
```

Po změně skriptů lze znovu spustit `vagrant provision`. Jedinečné jméno ve tvaru `spos-freebsd-xxxxxxxxxxxx` se ukládá do `/var/db/zabbix7-agent/spos-hostname` ve VM. Přežije restart i opakovaný provisioning. Nová VM vytvořená po `vagrant destroy` dostane nové jméno.

Instalační skript při `pkg update`, `pkg upgrade` a instalaci nastavuje `IGNORE_OSVERSION=yes` kvůli dříve zjištěnému rozdílu mezi verzí FreeBSD v boxu a repozitářem balíčků. `pkg upgrade` aktualizuje balíčky, nikoli základní systém FreeBSD.

## Ověření

Po spuštění VM:

```sh
vagrant ssh
cat /var/db/zabbix7-agent/spos-hostname
pkg info zabbix7-agent
/usr/local/sbin/zabbix_agentd -V
service zabbix_agentd status
grep -E '^(Hostname|Server|ServerActive|HostMetadata)=' /usr/local/etc/zabbix7/zabbix_agentd.conf
getent hosts enceladus.pfsense.cz
nc -z -w 5 enceladus.pfsense.cz 10051
sockstat -4 -l | grep 10050
```

V Zabbixu je registrovaný host `spos-freebsd-6b44fe09e1be` ve skupinách `Customer/SPOS` a `Discovered hosts` se šablonou `FreeBSD by Zabbix agent active`:

![Host FreeBSD v Zabbixu se skupinami a šablonou](Images/FBSD-ZBX8-Agent-reg.png)

Dashboard téhož hosta ukazuje naměřené hodnoty zatížení a využití CPU, paměti, swapu a souborových systémů za posledních pět minut. Tím je doložený příjem dat ze šablony s aktivními kontrolami:

![Naměřené hodnoty hosta FreeBSD v Zabbixu](Images/FBSD-ZBX8-Agent-reg-Data.png)

Na snímcích není vidět hodnota přiřazeného štítku; tu lze ověřit na záložce `Tags` v detailu hosta.

## Soubory

- `Vagrantfile`: FreeBSD box a automatický provisioning.
- `install-zabbix7-agent.sh`: instalace balíčku a kontrola verze 7.0.
- `configure-zabbix7-agent.sh`: stálé jméno hosta, nastavení agenta a spuštění služby.
- `Images/freebsd-zabbix-hero.png`: tematická ilustrace, nikoli důkaz monitorování.
- `Images/FBSD-ZBX8-Agent-reg.png`: dodaný snímek hosta z webového rozhraní Zabbixu.
- `Images/FBSD-ZBX8-Agent-reg-Data.png`: dashboard s naměřenými daty téhož hosta.

## Zdroje

- [FreeBSD port zabbix7-agent](https://www.freshports.org/net-mgmt/zabbix7-agent/)
- [Zabbix 7.0: konfigurace klasického agenta](https://www.zabbix.com/documentation/7.0/en/manual/appendix/config/zabbix_agentd)
- [Zabbix 7.0: automatická registrace](https://www.zabbix.com/documentation/7.0/en/manual/discovery/auto_registration)
