#!/usr/bin/env bash

#Author: Bakhtiyar Syed
#Institution: IIIT Hyderabad
#Date: 28 November 2016

#interact

chmod +x $0

usr=$1;
passwd=$2;

# Run in root if not already running in it
if [[ $(whoami) != "root" ]]; then
	xhost +SI:localuser:root
	sudo "$0" "$@"
	xhost -SI:localuser:root
	exit
fi


command -v zenity >/dev/null 2>&1 || {
if command -v apt-get 2&>1; then
	apt-get update; apt-get install -y zenity;
elif command -v dnf 2&>1; then
	dnf install -y zenity
fi
}

# Ask user to connect/disconnect

job=`zenity --entry --height=160 --width=400 --text="Enter to connect (C) or disconnect (D)" --title="Welcome to AutoVPN"`
# if connect

if [ $job == "connect" -o $job == "c" -o $job == "C" ]
then 
	#[ -z $usr ] && read -p "Enter username: " -a usr
	#[ -z $passwd ] && read -s -p "Enter password: " -a passwd


	[ -z $usr ] && usr="$(zenity --entry --height=160 --width=400 --text="Enter your IIIT-H email ID" --title=Authentication)"

	# Escape dollars and remove new line characters in usr

	usr=$(echo "$usr"| sed  's/\$/\\\$/g')
	usr="${usr//$'\\n'/}"

	if [ -z $usr ]
	then 
		`zenity --error --text="Username cannot be blank/Cancelled"`
		exit
	fi       
	[ -z $passwd ] && passwd="$(zenity --password --height=160 --width=400 --text="Please enter your password" --title=Authentication)"
	cd;

	# Escape dollars and remove new line characters in passwd

	passwd=$(echo "$passwd"| sed  's/\$/\\\$/g')
	passwd="${passwd//$'\\n'/}"

	if [ -z $passwd ] 
	then 
	#	echo Password cannot be blank!
		`zenity --error --text="Password cannot be blank/Cancelled"`
		exit
	fi
	command -v openvpn >/dev/null 2>&1 || {
	if command -v apt-get 2&>1; then    # Ubuntu based distros
		apt-get update; apt-get install -y openvpn;
	elif command -v dnf 2&>1; then      # Fedora based distros
		dnf install -y openvpn
	fi
}
command -v expect >/dev/null 2>&1 || {
if command -v apt-get 2&>1; then    # Ubuntu based distros
	apt-get update; apt-get install -y expect;
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
	rm -f ca.crt
fi
wget https://vpn.iiit.ac.in/ca.crt
if [  -e "all.iiit.ac.in.crt" ] || [ -e "all.iiit.ac.in.crt.*" ];
then
	rm -f all.iiit.ac.in.crt;
	rm -f all.iiit.ac.in.crt.*;
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
#usr=$(echo "$usr"| sed  's/\$/\\\$/g')
#usr="${usr//$'\\n'/}"
#passwd=$(echo "$passwd"| sed  's/\$/\\\$/g')
#passwd="${passwd//$'\\n'/}"

#Remove newline chars
#dt=${dt//$'\n'/}
#dt=${dt//$'\n'/}

#usr="${usr//$'\\n'/}"
#passwd="${passwd//$'\\n'/}"

#passwd="$(echo "$passwd" | sed -e 's/\n//g')"



#echo $passwd
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

if ! ping -c1 moodle.iiit.ac.in &>/dev/null
then 
	zenity --error --height=100 --width=400 --title="An Error Occurred" --text="VPN failed to start. Contact the administrator or see troubleshooting on github.com/flyingcharge/AutoVPN"
else
	zenity --info --title="SUCCESS" --text="VPN SUCCESSFULLY RUNNING!"
fi
sleep 3;
#num=`history | tail -n 2 | head -n 1 | tr -s ' ' | cut -d ' ' -f 2`;

#history -c;

#export HISTFILE=/dev/null
# if disconnect 

elif [ $job == "disconnect" -o $job == "d" -o $job == "D" ] 
then

# AUTHOR : MEGH PARIKH
# INSTITUTION : IIIT HYDERABAD
# DATE : 3 December 2017 (commit date on github)

	if [[ $(whoami) != "root" ]]; then
		sudo "$0" "$@"
		exit
	fi

	pkill openvpn
	sed -i '/nameserver 10.4.20.204/d' /etc/resolv.conf
#	echo Disconnected successfully!
	`zenity --info --text="DISCONNECTED SUCCESSFULLY!!" --title="SUCCESS!"`

	# for anything else 

else 

	`zenity --width=200 --height=160 --error --text="Enter C/D only "`

fi
