## Clear all rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
ip6tables -F
ip6tables -X
## Drop policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
## Dropping anything that masks ipv4 in the form of ipv6
iptables -I INPUT -p 41 -j DROP
ip6tables -I INPUT -p 41 -j DROP
## Disable portscan
iptables -I INPUT -p tcp --match recent --update --seconds 60 --name TCP-PORTSCAN -j DROP
iptables -I OUTPUT -p tcp --match recent --update --seconds 60 --name TCP-PORTSCAN -j DROP
iptables -I FORWARD -p tcp --match recent --update --seconds 60 --name TCP-PORTSCAN -j DROP
## Disable shell shocks
iptables -A INPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
iptables -A FORWARD -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
ip6tables -A INPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
iptables -A OUTPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
ip6tables -A OUTPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP
## Accept loopback interface
iptables -I INPUT -i lo -j ACCEPT
iptables -I OUTPUT -o lo -j ACCEPT
## Accept anything on udp
iptables -I INPUT -p udp -j ACCEPT
iptables -I OUTPUT -p udp -j ACCEPT
## Accept anything on port 443 and 80
iptables -I INPUT -p tcp -m conntrack --ctstate RELATED,ESTABLISHED --dport 443 -j ACCEPT
iptables -I INPUT -p tcp -m conntrack --ctstate RELATED,ESTABLISHED --dport 80 -j ACCEPT
## Accept outgoing on ports 443 and 80
iptables -I OUTPUT -p tcp -m multiport --dports 443,80 -j ACCEPT
