#!/bin/env bash

# ###################################################
# # Script Shell para Configuração de DHCP Server # #
# ###################################################

# --- Definições ---
DHCP_IF="enp0s3"      # Interface utilizada no DHCP Server


# Função que configura a interface utilizada pelo DHCP Server
function dchp_interf () {

    sudo echo "INTERFACESv4=$DHCP_IF" > /etc/default/isc-dhcp-server
}

# Função de instalação do isc-dhcp-server
function dhcp-server_install () {

    echo -e "Instalando o 'isc-dhcp-server'"
    sudo apt install isc-dhcp-server -y > /dev/null 2>&1
    sudo systemctl stop isc-dhcp-server > /dev/null 2>&1

    # sudo systemctl is-active --quiet isc-dhcp-server.service > /dev/null 2>&1
    # if [[ $? -ne 0 ]]
    # then
    #     echo -e "Não foi possível iniciar o serviço do isc-dhcp-server.\nVerifique o seu computador"
    #     exit 1
    # fi
}

dchp_interf
dhcp-server_install