#!/usr/bin/env bash

#Author: Bakhtiyar Syed
#Institution: IIIT Hyderabad
#Date: 28 November 2016

#interact

chmod +x $0

usr=$1;
passwd=$2;

cd;
command -v openvpn >/dev/null 2>&1 || { apt-get update; apt-get install openvpn; }
command -v expect >/dev/null 2>&1 || { apt-get update; apt-get install expect;
}

if grep -q  "nameserver 10.4.20.204" "/etc/resolv.conf";
then
sed -i '/nameserver 10.4.20.204/d' /etc/resolv.conf
fi
#apt-get update;



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
	wget https://vpn.iiit.ac.in/secure/all.iiit.ac.in.key --user=$usr --password=$passwd
fi

chmod 600 all.iiit.ac.in.key;

if [ ! -e "linux_client.conf" ];
then
	wget https://vpn.iiit.ac.in/linux_client.conf
fi



expect <<- DONE

	spawn openvpn --config linux_client.conf;

	expect "Enter Auth Username:" { send "$usr\r" }

	expect "Enter Auth Password:" { send "$passwd\r" }

	expect "Initialization Sequence Completed"

	
	interact;
DONE

sleep 12;
if grep -q  "nameserver 10.4.20.204" "/etc/resolv.conf";
then
echo "Nameserver already set. No need for further setting up";
else
sed -i '1i\'"nameserver 10.4.20.204" /etc/resolv.conf;
fi

unset HISTFILE;
