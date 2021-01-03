# Sleep for 10 seconds for the phone to start up properly, make sure to change the sleep time with respect to your device
sleep 10
# Set no executable permission on /data/local/tmp except for root user
chmod 0000 /data/local/tmp/
# Mount the /system partition as read-only
mount -o ro,remount /system
# change the ownership of /data/local/tmp to root only
chown 0.0 /data/local/tmp

# Hardened iptable rules
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP

## Accept anything on loopback
iptables -I INPUT -i lo -j ACCEPT
iptables -I OUTPUT -o lo -j ACCEPT

## Accept anything on 443 and 80
iptables -I OUTPUT -p tcp -m multiport --dports 443,80 -j ACCEPT
iptables -I INPUT -p tcp -m state --state RELATED,ESTABLISHED --sport 443 -j ACCEPT
iptables -I INPUT -p tcp -m state --state RELATED,ESTABLISHED --sport 80 -j ACCEPT

## Drop anything going out of ports 8001 to 65535
iptables -I OUTPUT -p tcp --dport 8001:65535 -j DROP

## udp rules
iptables -I INPUT -p udp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -I OUTPUT -p udp -j ACCEPT

# Accept udp on port 443 for dnscrypt proxy
#iptables -I OUTPUT -p udp --sport 443 -j ACCEPT

## Block ipv6 spoofing in the form of ipv4
iptables -A INPUT -p 41 -j DROP
ip6tables -A INPUT -p 41 -j DROP

# NTP, time server syncs using ntp port on udp 123, if you want time to sync, uncomment the following 5 lines (:
iptables -I INPUT -p tcp --dport 123 -j DROP
iptables -I OUTPUT -p tcp --dport 123 -j DROP
iptables -I OUTPUT -p udp --dport 123 -j DROP
iptables -I FORWARD -p udp --dport 123 -j DROP
iptables -I INPUT -p udp --dport 123 -j DROP

## Basically blocking all ping requests
iptables -I INPUT -p icmp -j DROP
iptables -I OUTPUT -p icmp -j DROP
iptables -I FORWARD -p icmp -j DROP
iptables -I INPUT -p icmp --icmp-type echo-reply -j DROP
iptables -I INPUT -p icmp --icmp-type echo-request -j DROP
iptables -I OUTPUT -p icmp --icmp-type echo-reply -j DROP
iptables -I OUTPUT -p icmp --icmp-type echo-request -j DROP
iptables -I FORWARD -p icmp --icmp-type echo-request -j DROP

## Block portscans
iptables -I INPUT -p tcp --match recent --update --seconds 60 --name TCP-PORTSCAN -j DROP
iptables -I OUTPUT -p tcp --match recent --update --seconds 60 --name TCP-PORTSCAN -j DROP
iptables -I FORWARD -p udp --match recent --update --seconds 60 --name UDP-PORTSCAN -j DROP
iptables -I INPUT -p udp --match recent --update --seconds 60 --name UDP-PORTSCAN -j DROP

## Dropping invalid packets
iptables -I INPUT -m state --state INVALID -j DROP
iptables -I OUTPUT -m state --state INVALID -j DROP
iptables -I INPUT -p tcp -m tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -I INPUT -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -I INPUT -p tcp -m state --state NEW -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -j DROP
iptables -I FORWARD -p tcp -m tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -I FORWARD -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -I FORWARD -p tcp -m state --state NEW -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -j DROP
iptables -I OUTPUT -p tcp -m tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -I OUTPUT -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -I OUTPUT -p tcp -m state --state NEW -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -j DROP

## Block shell shocks
iptables -A INPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
iptables -A FORWARD -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
ip6tables -A INPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
iptables -A OUTPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
iptables -A OUTPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
ip6tables -A OUTPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP

# Arbitrary suspicious port blocking.
iptables -I INPUT -p tcp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I FORWARD -p tcp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I INPUT -p tcp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I INPUT -p udp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I INPUT -p udp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I FORWARD -p udp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I OUTPUT -p tcp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I OUTPUT -p tcp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I OUTPUT -p udp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
iptables -I OUTPUT -p udp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP

#
# If mobile chain is present, then apply these
#iptables -I mobile -p udp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
#iptables -I mobile -p udp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
#iptables -I mobile -p tcp -m multiport --sports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
#iptables -I mobile -p tcp -m multiport --dports 21,23,22,2022,2222,8022,5901,5222,5228,1234,12345,8080,8006,9050,9090 -j DROP
#

# Dropping everything only on port 8443 because maximum multiport limit is 15
iptables -I INPUT -p tcp -m multiport --dports 8443 -j DROP
iptables -I FORWARD -p tcp -m multiport --dports 8443 -j DROP
iptables -I FORWARD -p tcp -m multiport --sports 8443 -j DROP
iptables -I FORWARD -p udp -m multiport --dports 8443 -j DROP
iptables -I FORWARD -p udp -m multiport --sports 8443 -j DROP
iptables -I INPUT -p tcp -m multiport --sports 8443 -j DROP
iptables -I INPUT -p udp -m multiport --dports 8443 -j DROP
iptables -I INPUT -p udp -m multiport --sports 8443 -j DROP
iptables -I OUTPUT -p tcp -m multiport --dports 8443 -j DROP
iptables -I OUTPUT -p tcp -m multiport --sports 8443 -j DROP
iptables -I OUTPUT -p udp -m multiport --dports 8443 -j DROP
iptables -I OUTPUT -p udp -m multiport --sports 8443 -j DROP

#
# If mobile chain is present, then apply these
#iptables -I mobile -p udp -m multiport --sports 8443 -j DROP
#iptables -I mobile -p udp -m multiport --dports 8443 -j DROP
#iptables -I mobile -p tcp -m multiport --sports 8443 -j DROP
#iptables -I mobile -p tcp -m multiport --dports 8443 -j DROP
#

## Tether settings

## Uncomment the following 17 or 18 lines for blocking all internet connections to every app on phone while tethering.

# We'll be using uid based internet access blocking for Android apps since Android implements SELinux policies. To get the uid's of all the apps, use this script

#for i in $(pm list packages | sed 's/package://g'); do
#	pm dump $i | grep userId | awk '{ print $1 }' | sed 's/userId=//g' | grep -v launch >> /path/to/uid.txt
#done
#
# Then locate the file and block all apps from accessing internet
#for i in $(cat /path/to/uid.txt); do
#iptables -I INPUT -m owner --uid-owner $i -j DROP
#iptables -I OUTPUT -m owner --uid-owner $i -j DROP
#iptables -I FORWARD -m owner --uid-owner $i -j DROP
#done

# For blocking root internet access to root
#iptables -I INPUT -m owner --uid-owner 0 -j DROP
#iptables -I OUTPUT -m owner --uid-owner 0 -j DROP
#iptables -I FORWARD -m owner --uid-owner 0 -j DROP

# When done, make sure to change the iptables policies to accept like so;
#iptables -P INPUT ACCEPT
#iptables -P OUTPUT ACCEPT
#iptables -P FORWARD ACCEPT

# Disable mobile data after boot
svc data disable
# Disable wifi after boot
svc wifi disable
# Disable adb access after boot, and unmount adb
umount /dev/usb-ffs/adb
# Disable executable permission for all busybox binaries if you're using magisk as your root manager
chmod 0000 /sbin/.magisk/busybox/*
