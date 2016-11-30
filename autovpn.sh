#!/usr/bin/env bash

#Author: Bakhtiyar Syed
#Institution: IIIT Hyderabad
#Date: 28 November 2016

#interact

chmod +x $0

usr=$1;
passwd=$2;

[ -z $usr ] && read -p "Enter username: " -a usr
[ -z $passwd ] && read -s -p "Enter password: " -a passwd

cd;
command -v openvpn >/dev/null 2>&1 || {
	if command -v apt-get 2&>1; then    # Ubuntu based distros
		apt-get update; apt-get install -y openvpn;
	elif command -v dnf 2&>1; then      # Fedora based distros
		dnf install -y openvpn
	fi
}
if command -v apt-get 2&>1; then    # Ubuntu based distros
	if [ $(dpkg-query -W -f='${Status}' openresolv 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		apt-get -y install openresolv;
	fi
elif command -v dnf 2&>1; then
	if ! rpm -qa | grep -qw openresolv; then
	    dnf install -y openresolv
	fi     # Fedora based distros
fi

cd /etc/openvpn;
if [ ! -e "ca.crt" ];
then
	wget https://vpn.iiit.ac.in/ca.crt
fi
if [ ! -e "all.iiit.ac.in.crt" ];
then
	wget https://vpn.iiit.ac.in/all.iiit.ac.in.crt
fi
if [ ! -e "all.iiit.ac.in.key" ];
then
	wget https://vpn.iiit.ac.in/secure/all.iiit.ac.in.key --user="$usr" --password="$passwd"
fi

chmod 600 all.iiit.ac.in.key;

if [ ! -e "linux_client.conf" ];
then
	wget https://vpn.iiit.ac.in/linux_client.conf
	echo 'auth-user-pass auth.txt'  >> linux_client.conf
	echo 'script-security 2'  >> linux_client.conf
	echo 'up "/etc/openvpn/update-resolv-conf.sh"'  >> linux_client.conf
	echo 'down "/etc/openvpn/update-resolv-conf.sh"' >> linux_client.conf
fi

if [ ! -e "update-resolv-conf.sh" ];
then
	wget https://raw.githubusercontent.com/mukulhase/openvpn-update-resolv-conf/master/update-resolv-conf.sh
fi
chmod +x update-resolv-conf.sh

# Escape dollars in usr and passwd for expect's send
usr=$(echo "$usr"| sed  's/\$/\\\$/g')
passwd=$(echo "$passwd"| sed  's/\$/\\\$/g')
echo "$usr" > auth.txt
echo "$passwd" >> auth.txt
chmod 700 auth.txt

echo 'alias vpn="cd /etc/openvpn;sudo openvpn --config linux_client.conf"' >> ~/.bash_aliases

openvpn --config linux_client.conf

#num=`history | tail -n 2 | head -n 1 | tr -s ' ' | cut -d ' ' -f 2`;

#history -c;

#export HISTFILE=/dev/null
