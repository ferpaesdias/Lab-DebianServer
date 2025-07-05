#!/bin/env bash

# #####################################################################
# # Script Shell para Configuração de Firewall de Borda com NFTables  #
# #####################################################################

# --- Definições ---
WAN_IF="enp0s3"      # Interface conectada à Internet
LAN_IF="enp0s8"      # Interface conectada à rede local
LAN_NET="172.16.0.0/24"  # Endereçamento da sua rede local
IP_SERVER01="172.16.0.200" # Endereço do servidor Server01


# Função de instalação do nftables
function nft_install () {

    echo -e "Instalando o 'nftables'"
    sudo apt install nftables -y > /dev/null 2>&1
    sudo systemctl stop nftables > /dev/null 2>&1

    sudo systemctl is-active --quiet nftables.service > /dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        echo -e "Não foi possível iniciar o serviço do nftables.\nVerifique o seu computador"
        exit 1
    fi
}

# Função que verifica se o nft está instalado e o instala se necessário
function nft_check () {

    sudo which nft > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        echo -e "Seu sistema já possui o 'nftables' instalado\n"
    else
        # Chama a função que instala o nftables
        nft_install
    fi
}

# Função que habilita o encaminhamento de porta do firewall
function check_forward () {

    sudo grep -Eq '^net\.ipv4\.ip_forward\s*=\s*1' /etc/sysctl.conf 

    if [[ $? -ne 0 ]]
    then
        echo "não tem"
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
    fi

    # Aplica a configuração
    sudo sysctl -p > /dev/null 2>&1
}


function nft_config () {

    echo "=== Iniciando configuração do firewall NFTables ==="

    # 1. Limpa todas as regras existentes para um início limpo
    sudo nft flush ruleset
    echo "[OK] Regras antigas removidas."

    # 2. Cria as tabelas 'filter' e 'nat'
    sudo nft add table inet filter
    sudo nft add table ip nat
    echo "[OK] Tabelas 'filter' e 'nat' criadas."

    # 3. Cria as cadeias (chains) e define as políticas padrão (Default Deny)

    # Tabela 'filter'
    sudo nft add chain inet filter INPUT { type filter hook input priority 0 \; policy drop \; }
    sudo nft add chain inet filter FORWARD { type filter hook forward priority 0 \; policy drop \; }
    sudo nft add chain inet filter OUTPUT { type filter hook output priority 0 \; policy accept \; }
    echo "[OK] Cadeias da tabela 'filter' criadas com política 'drop'."

    # Tabela 'nat'
    sudo nft add chain ip nat PREROUTING { type nat hook prerouting priority -100 \; }
    sudo nft add chain ip nat POSTROUTING { type nat hook postrouting priority 100 \; }
    echo "[OK] Cadeias da tabela 'nat' criadas."

    # 4. Adiciona as regras de firewall

    # --- Regras da cadeia INPUT (tráfego para o próprio firewall) ---
    sudo nft add rule inet filter INPUT ct state established,related accept
    sudo nft add rule inet filter INPUT iifname "lo" accept
    sudo nft add rule inet filter INPUT iifname $LAN_IF accept
    sudo nft add rule inet filter INPUT ct state invalid drop
    sudo nft add rule inet filter INPUT iifname $WAN_IF icmp type echo-request limit rate 5/second accept
    
    # (Opcional) Descomente para permitir SSH a partir da WAN
    sudo nft add rule inet filter INPUT iifname $WAN_IF tcp dport 22 accept
    echo "[OK] Regras da cadeia INPUT aplicadas."

    # --- Regras da cadeia FORWARD (tráfego passando pelo firewall) ---
    sudo nft add rule inet filter FORWARD iifname $WAN_IF oifname $LAN_IF ct state established,related accept
    sudo nft add rule inet filter FORWARD iifname $LAN_IF oifname $WAN_IF accept
    sudo nft add rule inet filter FORWARD ct state invalid drop
    
    # (Opcional) Regra de filtro para o redirecionamento de porta HTTP
    nft add rule inet filter FORWARD iifname $WAN_IF oifname $LAN_IF tcp dport 22 accept
    echo "[OK] Regras da cadeia FORWARD aplicadas."

    # --- Regras da tabela 'nat' ---

    # Regra de Masquerade (essencial para a LAN acessar a internet)
    sudo nft add rule ip nat POSTROUTING oifname $WAN_IF masquerade

    # (Opcional) Regra de Redirecionamento de Porta (DNAT)
    # sudo nft add rule ip nat PREROUTING iifname $WAN_IF tcp dport 80 dnat to $IP_SERVER01

    # (Opcional) Regra de Redirecionamento da Porta 2223 (DNAT) para a porta 22
    # sudo nft add rule ip nat PREROUTING iifname $WAN_IF tcp dport 2223 dnat to $IP_SERVER01:22
    echo "[OK] Regras de NAT aplicadas."

    # Tornar as configurações permanentes
    sudo sh -c "nft list ruleset > /etc/nftables.conf"
    echo "[OK] Regras configurados de forma permanente"

    # Reiniciar o serviços nftables para aplicar as configurações
    sudo systemctl restart nftables

    echo ""
    echo "=== Firewall NFTables configurado com sucesso! ==="
    echo "Visualizando o conjunto de regras ativo:"
    echo ""
    # Exibe o resultado final
    nft list ruleset
}

#### Execução dos comandos

# Verifica e instala o nftables
nft_check

# Habilita encaminhamento de pacotes
check_forward

# Configura o nftables
nft_config