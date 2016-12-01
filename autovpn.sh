#!/usr/bin/env bash

#Author: Bakhtiyar Syed
#Institution: IIIT Hyderabad
#Date: 28 November 2016

#interact

chmod +x $0

usr=$1;
passwd=$2;

command -v zenity >/dev/null 2>&1 || {
        if command -v apt-get 2&>1; then
                apt-get update; apt-get install zenity;
        elif command -v dnf 2&>1; then
                dnf install zenity
        fi
}




#[ -z $usr ] && read -p "Enter username: " -a usr
#[ -z $passwd ] && read -s -p "Enter password: " -a passwd


[ -z $usr ] && usr="$(zenity --entry --height=160 --width=400 --text="Enter your IIIT-H email ID" --title=Authentication)"
[ -z $passwd ] && passwd="$(zenity --password --height=160 --width=400 --text="Please enter your password" --title=Authentication)"
cd;


command -v openvpn >/dev/null 2>&1 || {
	if command -v apt-get 2&>1; then    # Ubuntu based distros
		apt-get update; apt-get install openvpn;
	elif command -v dnf 2&>1; then      # Fedora based distros
		dnf install -y openvpn
	fi
}
command -v expect >/dev/null 2>&1 || {
	if command -v apt-get 2&>1; then    # Ubuntu based distros
		apt-get update; apt-get install expect;
	elif command -v dnf 2&>1; then      # Fedora based distros
		dnf install -y expect
	fi
}

if grep -q  "nameserver 10.4.20.204" "/etc/resolv.conf";
then
sed -i '/nameserver 10.4.20.204/d' /etc/resolv.conf
fi
#apt-get update;



cd /etc/openvpn;
#rm -rf *
if [ -e "ca.crt" ];
then
	rm ca.crt
fi

wget https://vpn.iiit.ac.in/ca.crt
if [  -e "all.iiit.ac.in.crt" ];
then
	rm -f https://vpn.iiit.ac.in/all.iiit.ac.in.crt
fi

wget https://vpn.iiit.ac.in/all.iiit.ac.in.crt
if [  -e "all.iiit.ac.in.key" ];
then
	rm all.iiit.ac.in.key
fi

curl -O --user "$usr":"$passwd" https://vpn.iiit.ac.in/secure/all.iiit.ac.in.key

#fi

chmod 600 all.iiit.ac.in.key;
if [ -e "linux_client.conf" ];
then
	rm -f linux_client.conf;
fi

wget https://vpn.iiit.ac.in/linux_client.conf

# Escape dollars in usr and passwd for expect's send
usr=$(echo "$usr"| sed  's/\$/\\\$/g')
passwd=$(echo "$passwd"| sed  's/\$/\\\$/g')

#Remove newline chars
#dt=${dt//$'\n'/}
#dt=${dt//$'\n'/}
usr="${usr//$'\\n'/}"
passwd="${passwd//$'\\n'/}"
#passwd="$(echo "$passwd" | sed -e 's/\n//g')"



echo $passwd
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

zenity --info --title="SUCCESS" --text="VPN SUCCESSFULLY RUNNING!"

sleep 3;
#num=`history | tail -n 2 | head -n 1 | tr -s ' ' | cut -d ' ' -f 2`;

#history -c;

#export HISTFILE=/dev/null
