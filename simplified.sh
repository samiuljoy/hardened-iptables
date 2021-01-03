## Clear all rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -t mangle -X
iptables -t nat -X
ip6tables -F
ip6tables -X

## Drop all policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

## Accept loopback interface
iptables -I INPUT -i lo -j ACCEPT

# Accepting on output is optional
iptables -I OUTPUT -o lo -j ACCEPT

## Accept anything on udp
iptables -I OUTPUT -p udp -j ACCEPT

## Alternatively, you can set the rule to accept only on udp port 67 or 53 just for DNS requests, and basically drop everything else
# iptables -I INPUT -p udp -m multiport --dports 53,67 -j ACCEPT

## Accept input for udp, but only related and established
iptables -I INPUT -p udp -m state --state RELATED,ESTABLISHED -j ACCEPT

## Accept anything on port 443 and 80
iptables -I INPUT -p tcp -m conntrack --ctstate RELATED,ESTABLISHED --sport 443 -j ACCEPT
iptables -I INPUT -p tcp -m conntrack --ctstate RELATED,ESTABLISHED --sport 80 -j ACCEPT

## Accept outgoing on ports 443 and 80
iptables -I OUTPUT -p tcp -m multiport --dports 443,80 -j ACCEPT
