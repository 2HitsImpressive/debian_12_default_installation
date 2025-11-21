#!/bin/bash
# ==============================================
# Script de instalación LXQt en Debian 12
# Mínimo y optimizado
# Autor: Adaptado de Enrique Rios
# ==============================================

# Variables configurables
USER="minie"
PASSWORD="abc123"

echo "=== Actualizando el sistema ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== Estableciendo zona horaria ==="
sudo timedatectl set-timezone America/Lima

echo "=== Instalando entorno gráfico mínimo (LXQt + Xorg + Openbox + Htop) ==="
# lightdm es el gestor de sesiones que te permitirá iniciar sesión gráficamente
sudo apt install -y lxqt-core xorg openbox lightdm htop

echo "=== Creando usuario $USER con privilegios administrativos ==="
if id "$USER" &>/dev/null; then
    echo "El usuario $USER ya existe, omitiendo creación."
else
    sudo adduser --disabled-password --gecos "" "$USER"
    echo "${USER}:${PASSWORD}" | sudo chpasswd
    sudo usermod -aG sudo "$USER"
    echo "Usuario $USER creado correctamente con permisos sudo."
fi

# Configurar sesión LXQt por defecto para el nuevo usuario
echo "lxqt-session" > /home/$USER/.xsession
sudo chmod +x /home/$USER/.xsession
sudo chown $USER:$USER /home/$USER/.xsession

# Copiar a /etc/skel para que futuros usuarios también tengan LXQt configurado
echo "lxqt-session" | sudo tee /etc/skel/.xsession > /dev/null

echo "=== Limpiando dependencias no utilizadas ==="
sudo apt autoremove -y
sudo apt clean

echo
echo "=== Instalación de LXQt completada correctamente ==="
echo "El entorno gráfico está instalado y el usuario $USER creado."
echo "Contraseña: $PASSWORD"
echo
echo "Para iniciar el entorno gráfico, debes reiniciar tu sistema."
echo "Puedes ejecutar el comando:"
echo "sudo reboot"
