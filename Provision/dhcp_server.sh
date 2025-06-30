#!/bin/env bash

# Instalação do DHCP Server 
function instalar_dhcp_server {

    sudo apt-get install isc-dhcp-server
}

# Indicar qual a interface de rede será utilizada
function dhcp_server_interface { 
    
    local dhcp_interf=$(ip -o address | grep "192.168.56.201" | awk -F' ' '{print $2}')

cat <<-EOF | sudo tee /etc/default/isc-dhcp-server
$dhcp_interf
EOF
}