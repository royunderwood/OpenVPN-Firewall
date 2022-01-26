#!/bin/bash

# Allow all loopback (lo) traffic and reject traffic
# to localhost that does not originate from lo.
# Change Variables

MyIP=10.0.0.0/24
MyDEV=$MyDEV

/sbin/iptables -F
/sbin/iptables -t nat -F
/sbin/iptables -X
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT
/sbin/iptables -A INPUT -i $MyDEV -j ACCEPT
/sbin/iptables -A OUTPUT -o $MyDEV -j ACCEPT
/sbin/iptables -t nat -A POSTROUTING -s $MyIP -o $MyDEV -j MASQUERADE

# Allow traffic on the TUN interface.
/sbin/iptables -A  INPUT -i tun0 -j ACCEPT
/sbin/iptables -A  FORWARD -i tun0 -j ACCEPT
/sbin/iptables -A  OUTPUT -o tun0 -j ACCEPT

# Allow forwarding traffic only from the VPN.
/sbin/iptables -A FORWARD -i $MyDEV -o tun+ -j ACCEPT
/sbin/iptables -A FORWARD -i $MyDEV -o tun+ -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
/sbin/iptables -t nat -A POSTROUTING -o $MyDEV -j MASQUERADE
/sbin/iptables -I FORWARD -o $MyDEV -i tun0 -j ACCEPT
/sbin/iptables -I FORWARD -i $MyDEV -o tun0 -j ACCEPT

# Allow incoming connections related to existing allowed connections.
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow ping and ICMP error returns.
/sbin/iptables -A  INPUT -p icmp -m state --state NEW --icmp-type 8 -j ACCEPT
/sbin/iptables -A  INPUT -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A  OUTPUT -p icmp -j ACCEPT

# Allow UDP traffic on port 1194.                                                                                                               
/sbin/iptables -A  INPUT -i ens192 -p udp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT                                               
/sbin/iptables -A  OUTPUT -o ens192 -p udp -m state --state ESTABLISHED --sport 1194 -j ACCEPT                                                  
/sbin/iptables -A  INPUT -i ens192 -p tcp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT                                               
/sbin/iptables -A  OUTPUT -o ens192 -p tcp -m state --state ESTABLISHED --sport 1194 -j ACCEPT  

#Place Other Rules Here, i.e. SSH/EMAIL/SQL etc...
