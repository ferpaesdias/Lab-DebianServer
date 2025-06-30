#!/bin/env bash

source /vagrant/Provision/config_inicial.sh

# Ajustar o fuso horário 
echo -e "Ajustando fuso horário"
fuso_horario


# Ajustar os arquivos host e resolv.conf 
echo -e "Ajustando fuso horário"
hosts_resolv 


# Instalar aplicativos básicos
echo -e "Ajustando fuso horário"
apps_basicos


# Instalação do DHCP Server 
function dhcp_server {

    sudo apt-get install isc-dhcp-server
}


