# Firewall - nftables

<br>

Usarei o firewall **nftables** que já vem instalado no Debian.


O servidor Firewall tem 02 interfaces de rede: 

- **WAN**: Interface que tem conexão com a internet. Está configurada como DHCP Client.
- **LAN**: Interface da rede interna. Está configurada com o IP `172.16.0.1/24`.

<br>

O endereço de rede da LAN é `172.16.0.0/24`.


## Instalação

Apesar do Debian 12 já ter o **nftables** instalado por padrão, vou colocar aqui como instalá-lo.

<br>

**Passo 01**: Verifivar se o `nft` está instalado

O `nft` é comando que gerencia o **nftables**.

```bash
which nft
```

<br>

Se aparecer a mensagem `nft not found` significa que o `nft` não está instalado. Faça a instalação com o comando abaixo:

```bash
apt install nftables
```

<br>

Se, ao digitar o comando `which nft`, aparecer uma mensagem semelhante a `/usr/sbin/nft`, siga para o passo 02.

<br>

**Passo 02**: Ative e inicie o serviço do **nftables**

```bash
systemctl enable nftables
systemctl start nftables
```

<br>


## Criar regras

<br>

Para listar as regras existentes:

```bash
nft list ruleset
```

