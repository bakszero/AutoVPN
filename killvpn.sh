#!/usr/bin/env bash

if [[ $(whoami) != "root" ]]; then
	sudo "$0" "$@"
	exit
fi

pkill openvpn
sed -i '/nameserver 10.4.20.204/d' /etc/resolv.conf
