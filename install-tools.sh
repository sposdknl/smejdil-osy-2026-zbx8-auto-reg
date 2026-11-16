#!/bin/sh
set -eu

# Skript lze spustit i samostatně na novém FreeBSD boxu.
if ! pkg -N >/dev/null 2>&1; then
  env ASSUME_ALWAYS_YES=yes pkg bootstrap -f
fi
export IGNORE_OSVERSION=yes
pkg update
pkg install -y bash neofetch joe vim htop btop mc nmap git pkgconf muon samurai

# Existující strom portů při opakovaném provisioningu zachováme.
if [ ! -d /usr/ports ]; then
  git clone --depth 1 https://git.FreeBSD.org/ports.git /usr/ports
elif [ -z "$(ls -A /usr/ports)" ]; then
  git clone --depth 1 https://git.FreeBSD.org/ports.git /usr/ports
else
  printf 'Strom portů v /usr/ports již existuje, přeskakuji klonování.\n'
fi
