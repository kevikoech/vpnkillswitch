#!/bin/bash
#leak protection fail switch/vpn kill switch
IP=$(wget https://duckduckgo.com/?q=whats+my+ip -q -O - | grep -Eo '\<[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3}\>') 
echo "Your old IP is: "$IP "lets change that, shall we?"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
####
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT #allow loopback access
iptables -A OUTPUT -d 255.255.255.255 -j  ACCEPT #make sure  you can communicate with any DHCP server
iptables -A INPUT -s 255.255.255.255 -j ACCEPT #make sure you   can communicate with any DHCP server
iptables -A INPUT -s 192.168.0.0/16 -d 192.168.0.0/16 -j ACCEPT   #make sure that you can communicate within your own network
iptables -A OUTPUT -s 192.168.0.0/16 -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -i ppp0 -o tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o ppp0 -j ACCEPT # make sure that   eth+ and tun+ can communicate
iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE # in the   POSTROUTING chain of the NAT table, map the tun+ interface     outgoing packet IP address, cease examining rules and let the header  be modified, so that we don't have to worry about ports or any other  issue - please check this rule with care if you have already a NAT  table in your chain
iptables -A OUTPUT -o ppp0 ! -d $IP -j DROP  # if destination for    outgoing packet on eth+ is NOT a.b.c.d, drop the packet, so that    nothing leaks if VPN disconnects
echo "Your new ip is:" $IP

#curl icanhazip.com OR ifconfig.me

echo "all done big boy!"

exit 1
done


#Then vpnoff.sh when openvpn stop

#iptables -F