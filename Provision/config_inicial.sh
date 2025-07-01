#!/bin/env bash


# Ajuste do fuso horário  
function fuso_horario {

    # Ajuste fuso horario
    sudo timedatectl set-timezone America/Sao_Paulo
}

# Ajusta arquivo host e resolv.conf 
function hosts_resolv {

# Ajusta arquivo hosts
cat <<-EOF | sudo tee -a /etc/hosts
192.168.56.201 server01.lab.local
EOF

# Adiciona o DNS do Google no arquivo resolv.conf
cat <<-EOF | sudo tee /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
}

# Instalar aplicativos básicos
function apps_basicos {

    echo -e "Atualizando repositórios"
    sudo apt-get update #> /dev/null 2>&1 

    echo -e "Instalando aplicativos básicos"
    sudo apt-get install -qq vim curl wget apt-transport-https ca-certificates jq git
}
