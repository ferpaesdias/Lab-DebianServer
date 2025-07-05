#!/bin/env bash

# ###################################################
# # Script Shell para Configuração de DHCP Server # #
# ###################################################

# --- Definições ---
DHCP_IF="enp0s3"      # Interface utilizada no DHCP Server
DOMAIN="lab.local"
NAME_SERVERS="8.8.8.8, 8.8.4.4"
IP_RANGE="172.16.0.11 172.16.0.199"
IP_ROUTER="172.16.0.1"
SUBNET="172.16.0.0"
NETMASK="255.255.255.0"
DEFAULT_LEASE_TIME="600"
MAX_LEASE_TIME="7200"

# Função de instalação do isc-dhcp-server
function dhcpd_install () {

    echo -e "Instalando o 'isc-dhcp-server'"
    sudo apt install isc-dhcp-server -y > /dev/null 2>&1
}

#Função que reinicia o serviço do DHCP Server
function dhcpd_restart () {

    sudo systemctl restart isc-dhcp-server > /dev/null 2>&1
    sudo systemctl enable isc-dhcp-server > /dev/null 2>&1

    sudo systemctl is-active --quiet isc-dhcp-server.service > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        echo -e "Não foi possível iniciar o serviço do isc-dhcp-server.\nVerifique o seu computador"
        exit 1
    fi
    
}

# Função que verifica se o nft está instalado e o instala se necessário
function dhcpd_check () {

    sudo which dhcpd > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        echo -e "Seu sistema já possui o 'isc-dhcp-server' instalado\n"
    else
        # Chama a função que instala o isc-dhcp-server
        dhcpd_install
    fi
}

# Função que configura o DHCP Server
function dhcpd_config () {

    sudo echo "INTERFACESv4=$DHCP_IF" > /etc/default/isc-dhcp-server

    cat <<-EOF > /etc/dhcp/dhcpd.conf 
    default-lease-time $DEFAULT_LEASE_TIME;
    max-lease-time $MAX_LEASE_TIME;

    subnet $SUBNET netmask $NETMASK {
        range $IP_RANGE;
        option routers $IP_ROUTER;
        option domain-name-servers $NAME_SERVERS;
        option domain-name "$DOMAIN";
    }
EOF
}



#### Execução dos comandos

# Verifica e instala o isc-dhcp-server
dhcpd_check

# Configura o isc-dhcp-server
dhcpd_config

# Reinicia serviço para aplicar as configurações
dhcpd_restart