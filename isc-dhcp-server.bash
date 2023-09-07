#/bin/bash

clear
ip a
read -p "Ethernet interface (eth0)
" ethinterface
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
read -p "DNS (1.1.1.1 / 8.8.8.8)
" dnsserver
read -p "hostname (home.local)
" hostname
read -p "WDS server IP
" wds_server_ip
read -p "filename PXE for WDS (boot\\x64\\wdsnbp.com)
" filenamepxe
apt update
apt upgrade -y
apt install isc-dhcp-server -y
clear
sed -i {'s/#DHCPDv4_CONF=\/etc\/dhcp\/dhcpd.conf/DHCPDv4_CONF=\/etc\/dhcp\/dhcpd.conf/;s/INTERFACESv4=""/INTERFACESv4="'$ethinterface'"/;s/INTERFACESv6=""/#INTERFACESv6=""/'} /etc/default/isc-dhcp-server
rm /etc/dhcp/dhcpd.conf
echo "option domain-name \"$hostname\";
option domain-name-servers $dnsserver;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

authoritative;

option space PXE;
option PXE.mtftp-ip code 1 = ip-address;
option PXE.mtftp-cport code 2 = unsigned integer 16;
option PXE.mtftp-sport code 3 = unsigned integer 16;
option PXE.mtftp-tmout code 4 = unsigned integer 8;
option PXE.mtftp-delay code 5 = unsigned integer 8;
option PXE.discovery-control code 6 = unsigned integer 8;
option PXE.discovery-mcast-addr code 7 = ip-address;
option PXE.boot-server code 8 = ip-address;
option PXE.bootfile-name code 9 = text;

subnet $subnet netmask $netmask {
  range dynamic-bootp $rangestart $rangestop;
  option broadcast-address $broadcast;
  option routers $routers;

  # Configuration pour PXE Linux
  #next-server $pxeserver;  # Adresse IP du serveur PXE
  #filename \"pxelinux.0\"; # Nom du fichier de boot PXE

   # Option d'amorçage PXE pour WDS
    if substring (option vendor-class-identifier, 0, 9) = "PXEClient" {
        filename "$filenamepxe";
        next-server $wds_server_ip;
    }
}" > /etc/dhcp/dhcpd.conf
systemctl restart isc-dhcp-server
