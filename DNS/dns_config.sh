#!/bin/env bash

# ################################################
# # Script Shell para Configuração o DNS Server  #
# ################################################

# --- Definições ---
WAN_IF="enp0s3"      # Interface conectada à Internet
LAN_IF="enp0s8"      # Interface conectada à rede local
LAN_NET="172.16.0.0/24"  # Endereçamento da sua rede local
IP_SERVER01="172.16.0.200" # Endereço do servidor Server01



# Função de instalação do bind9
function bind9_install () {

    echo -e "Instalando o 'bind9'"
    sudo apt install bind9 bind9utils bind9-doc -y > /dev/null 2>&1
    sudo systemctl enable bind9 --now > /dev/null 2>&1

    # sudo systemctl is-active --quiet bind9.service > /dev/null 2>&1
    # if [[ $? -ne 0 ]]
    # then
    #     echo -e "Não foi possível iniciar o serviço do bind9.\nVerifique o seu computador"
    #     exit 1
    # fi
}

# Função que verifica se o nft está instalado e o instala se necessário
function bind9_check () {

    sudo which named > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        echo -e "Seu sistema já possui o 'nftables' instalado\n"
    else
        # Chama a função que instala o nftables
        bind9_install
    fi
}

# Função que configura o DNS Server
function bind9_config () {

    sudo echo 'OPTIONS="-u bind -4"' > /etc/default/bind9

    cat <<-EOF > /etc/bind/named.conf.options
    acl "trusted" {
        172.0.0.1;      # localhost
        172.16.0.0/24;  # Rede local
    };

    options {
        directory "/var/cache/bind";

        // Permite somente consultas da rede local
        allow-query { trusted; };

        // Encaminhadores
        forwarders {
            8.8.8.8;
            8.8.4.4;
        }; 

        // Ativa o encaminhamento
        forward only;
    };
EOF

    cat <<-EOF > /etc/bind/named.conf.local  
    // Zona para resolver nomes como 'servidor.lao.local'
    zone "mylab.lan" {
        type master;
        file "/etc/bind/zones.db.mylab.lan"; // Arquivo de registro de nomes
    };

    // Zonas reversa
    zone "200.0.16.172.in-addr.arpa" {
        type master;
        file "/etc/bind/db.192"; //Arquivos com os registros de IPs
    };
EOF

    cat <<-EOF > /etc/bind/db.mylab.lan  
    ;
    ; BIND data file for local loopback interface
    ;
    \$TTL	604800
    @	IN	SOA	server01.mylab.lan. root.mylab.lan. (
    			      2		; Serial
    			 604800		; Refresh
    			  86400		; Retry
    			2419200		; Expire
    			 604800 )	; Negative Cache TTL
    ;
    @	IN	NS	localhost.
    
    server	IN	A	172.16.0.200
    firewall	IN	A	172.16.0.1
    @	IN	A	127.0.0.1
EOF


    cat <<-EOF > /etc/bind/db.172 
    ;
    ; BIND reverse data file for local loopback interface
    ;
    \$TTL	604800
    @	IN	SOA	mylab.lan. root.mylab.lan. (
    			      1		; Serial
    			 604800		; Refresh
    			  86400		; Retry
    			2419200		; Expire
    			 604800 )	; Negative Cache TTL
    ;
    @	IN	NS	localhost.


    200	IN	PTR	server01.mylab.lan.
    1	IN	PTR	firewall.mylab.lan.
EOF
}


bind9_check

bind9_config
