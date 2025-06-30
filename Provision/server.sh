#!/bin/env bash

source /vagrant/Provision/config_inicial.sh
source /vagrant/Provision/dhcp_server.sh

# Ajustar o fuso horário 
echo -e "Ajustando fuso horário"
fuso_horario

# Ajustar os arquivos host e resolv.conf 
echo -e "Ajustando fuso horário"
hosts_resolv 

# Instalar aplicativos básicos
echo -e "Ajustando fuso horário"
apps_basicos

# Instalar o DHCP Server
echo -e "Instalar o DHCP Server"
instalar_dhcp_server

# Configurar DHCP Server
dhcp_server_interface


