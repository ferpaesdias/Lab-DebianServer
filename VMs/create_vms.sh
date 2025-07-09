#!/bin/env bash

# ######################################################
# # Script Shell para a criação de VMs nos Virtual Box #
# ######################################################


# --- Variáveis de Configuração ---
VM_NAME="debian-client01"
RAM_MB="1024"
CPU_COUNT="1"
DISK_SIZE_MB="20480" # 20 GB
# IMPORTANTE: Mude para o caminho do seu ISO modificado
ISO_PATH="/home/fernando/Downloads/ISOs/debian-12-preseed.iso"

# --- Caminhos ---
VM_DIR="$HOME/VirtualBox VMs/$VM_NAME"
VDI_PATH="$VM_DIR/$VM_NAME.vdi"

# --- Lógica do Script ---
echo "=> Criando VM: $VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Debian_64" --register

echo "=> Configurando memória e CPU..."
VBoxManage modifyvm "$VM_NAME" --memory "$RAM_MB" --cpus "$CPU_COUNT" --vram 16 --graphicscontroller vmsvga

echo "=> Configurando rede (NAT)..."
VBoxManage modifyvm "$VM_NAME" --nic1 nat

echo "=> Criando disco rígido virtual..."
mkdir -p "$VM_DIR"
VBoxManage createhd --filename "$VDI_PATH" --size "$DISK_SIZE_MB" --format VDI

echo "=> Adicionando controlador SATA..."
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci

echo "=> Anexando disco rígido e ISO de instalação..."
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_PATH"
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"

echo "=> VM '$VM_NAME' criada com sucesso!"
echo "Para iniciar, execute: VBoxManage startvm $VM_NAME"