# AutoVPN
Author: Bakhtiyar Syed

This is an automatic VPN installer/runner for IIIT-H students.


**Usage:**
~~~
1. After downloading the zip, extract it.

2. cd AutoVPN/ OR cd AutoVPN-master/ (depending on your mode of download via cloning or direct download.)

3. sudo ./autovpn.sh
~~~

(Your official IIIT-H students/research email and password must be entered when prompted.)

**Requirements:**
>
None (:

**Constraints:**
>
Works only on Ubuntu(apt-get package) and Fedora (dnf package) related systems right now.
You need to run the script with root access(sudo).

**Troubleshooting**
>
The most common doubt everyone faces is how to proceed when they face a proxy error. This is not an error, it's just that you're no longer on the IIIT-H network and you need to unset your proxy environment variables. 
If you haven't yet unset your proxy variables, here's the way:

```
1. Open your terminal and type:
unset http_proxy ; unset https_proxy ; unset HTTP_PROXY ; unset HTTPS_PROXY

2. You have to go to network settings and change proxy to None. 
Just changing in the browser does not help. Pretty obvious but yeah. 

3. Comment out everything there is in the file /etc/apt/apt.conf.d/99iiithproxy .
If the file does not exist, ignore.

4. If you're still unable to connect, a restart of your PC might be needed.
```



*Pull requests and suggestions for improvement are most welcome.*



