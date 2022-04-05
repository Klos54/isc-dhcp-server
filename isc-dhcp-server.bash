#/bin/bash

clear
read -p "Subnet (192.168.1.0)
" subnet
read -p "Netmask (255.255.255.0)
" netmask
read -p "Broadcast address (192.168.1.255)
" broadcast
read -p "Routers IP (192.168.1.1)
" routers
read -p "DHCP range start (192.168.1.100)
" rangestart
read -p "DHCP range stop (192.168.1.200)
" rangestop
apt update
apt upgrade -y
apt install isc-dhcp-server -y
clear
sed -i {'s/#DHCPDv4_CONF=\/etc\/dhcp\/dhcpd.conf/DHCPDv4_CONF=\/etc\/dhcp\/dhcpd.conf/;s/INTERFACESv4=""/INTERFACESv4="eth0"/;s/INTERFACESv6=""/#INTERFACESv6=""/'} /etc/default/isc-dhcp-server
rm /etc/dhcp/dhcpd.conf
echo "option domain-name \"home.local\";
option domain-name-servers 84.200.69.80;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

authoritative;

subnet $subnet netmask $netmask {
  range dynamic-bootp $rangestart $rangestop;
  option broadcast-address $broadcast;
  option routers $routers;
}" > /etc/dhcp/dhcpd.conf
systemctl restart isc-dhcp-server