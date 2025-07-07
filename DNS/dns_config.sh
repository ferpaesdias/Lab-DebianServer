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
	options {
	    directory "/var/cache/bind";

	    recursion yes; 
	    allow-query { 172.16.0.0/24; };

	    // Encaminhadores
	    forwarders {
	        8.8.8.8;
	        8.8.4.4;
	    }; 

	    dnssec-validation auto;
	    auth-nxdomain no;
	    listen-on { 127.0.0.1; 172.16.0.200; };
	    listen-on-v6 { none; };
	};
EOF

	cat <<-EOF > /etc/bind/named.conf.local  
	zone "mylab.lan" {
	    type master;
	    file "/etc/bind/db.mylab.lan"; 
	};

	zone "0.16.172.in-addr.arpa" {
	    type master;
	    file "/etc/bind/db.172";
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
	@	IN	NS	server01.mylab.lan.
	server01	IN	A	172.16.0.200
	firewall	IN	A	172.16.0.1
EOF


	cat <<-EOF > /etc/bind/db.172 
	;
	; BIND reverse data file for local loopback interface
	;
	\$TTL	604800
	@	IN	SOA	server01.mylab.lan. root.mylab.lan. (
	                  1		; Serial
	             604800		; Refresh
	              86400		; Retry
	            2419200		; Expire
	             604800 )	; Negative Cache TTL
	
	@	IN	NS	server01.mylab.lan.
	200	IN	PTR	server01.mylab.lan.
	1	IN	PTR	firewall.mylab.lan.
EOF
}


bind9_check

bind9_config
