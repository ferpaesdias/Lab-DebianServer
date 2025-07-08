#!/bin/env bash

# ###################################################
# # Script Shell para Configuração de DHCP Server # #
# ###################################################

# --- Definições ---
DHCP_IF="enp0s3"      # Interface utilizada no DHCP Server
DOMAIN="mylab.lan"
NAME_SERVERS="172.16.0.200"
IP_RANGE="172.16.0.11 - 172.16.0.99"
IP_ROUTER="172.16.0.1"
SUBNET="172.16.0.0/24"
NETMASK="255.255.255.0"
DEFAULT_LEASE_TIME="600"
MAX_LEASE_TIME="7200"

# Função de instalação do isc-dhcp-server
function dhcpd_install () {

    echo -e "Instalando o ' kea-dhcp4-server"
    sudo apt install kea-dhcp4-server -y > /dev/null 2>&1
}

#Função que reinicia o serviço do DHCP Server
function dhcpd_restart () {

    sudo systemctl restart kea-dhcp4-server.service > /dev/null 2>&1
    sudo systemctl enable kea-dhcp4-server.service > /dev/null 2>&1

    sudo systemctl is-active --quiet kea-dhcp4-server.service.service > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        echo -e "Não foi possível iniciar o serviço do kea-dhcp4-server.service.\nVerifique o seu computador"
        exit 1
    fi
    
}

# Função que verifica se o nft está instalado e o instala se necessário
function dhcpd_check () {

    sudo which dhcpd > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        echo -e "Seu sistema já possui o 'kea-dhcp4-server instalado\n"
    else
        # Chama a função que instala o isc-dhcp-server
        dhcpd_install
    fi
}

# Função que configura o DHCP Server
function dhcpd_config () {

    cat <<-EOF > /etc/kea/kea-dhcp4.conf
	{
	"Dhcp4": {
	// Interface de rede que o Kea vai ouvir
	"interfaces-config": {
	    "interfaces": [ "$DHCP_IF" ]
	},	
	// Tempo de concessão do IP (em segundos)
	"lease-database": {
	    "type": "memfile",
	    "persist": true,
	    "name": "/var/lib/kea/kea-leases4.csv"
	},	
	// Tempos de concessão (em segundos)
	"valid-lifetime": 4000,
	"renew-timer": 1000,
	"rebind-timer": 2000,	
	// Sub-rede para a qual o Kea servirá IPs
	"subnet4": [
	    {
	        "subnet": "$SUBNET",
	        "pools": [
	            {
	                // O range de IPs que será distribuído
	                "pool": "$IP_RANGE"
	            }
	        ],
	        // Opções que serão enviadas aos clientes DHCP
	        "option-data": [
	            {
	                // Gateway
	                "name": "routers",
	                "data": "$IP_ROUTER"
	            },
	            {
	                // Servidores DNS (o seu novo servidor!)
	                "name": "domain-name-servers",
	                "data": "$NAME_SERVERS"
	            },
	            {
	                // Domínio local
	                "name": "domain-name",
	                "data": "$DOMAIN"
	            }
	        ]
	    }
	]
	}
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