#!/bin/bash
# ==============================================
# Script de instalación LXQt en Debian 12
# Mínimo, optimizado y con limpieza de componentes
# Diseñado para EJECUCIÓN COMO USUARIO ROOT
# ==============================================

# Variables configurables
USER="minie"
PASSWORD="abc123"

echo "=== Actualizando el sistema ==="
apt update -y && apt upgrade -y

echo "=== Estableciendo zona horaria ==="
timedatectl set-timezone America/Lima

echo "=== Instalando entorno gráfico mínimo (LXQt + Xorg + Openbox + Htop) ==="
# lightdm es el gestor de sesiones que te permitirá iniciar sesión gráficamente
apt install -y lxqt-core xorg openbox lightdm htop

echo "=== Creando usuario $USER con privilegios administrativos ==="
if id "$USER" &>/dev/null; then
    echo "El usuario $USER ya existe, omitiendo creación."
else
    # Las herramientas de gestión de usuarios no necesitan sudo si se ejecutan como root
    adduser --disabled-password --gecos "" "$USER"
    echo "${USER}:${PASSWORD}" | chpasswd
    usermod -aG sudo "$USER"
    echo "Usuario $USER creado correctamente con permisos sudo."
fi

# Configurar sesión LXQt por defecto para el nuevo usuario
echo "lxqt-session" > /home/$USER/.xsession
chmod +x /home/$USER/.xsession
chown $USER:$USER /home/$USER/.xsession

# Copiar a /etc/skel para que futuros usuarios también tengan LXQt configurado
echo "lxqt-session" | tee /etc/skel/.xsession > /dev/null

# --- Sección crucial para reducir el consumo de RAM ---
echo "=== Eliminando componentes innecesarios para optimización de RAM ==="

apt remove -y lxqt-powermanagement qlipper lxqt-notificationd lxqt-runner xscreensaver xscreensaver-data xscreensaver-data-extra xscreensaver-gl gvfs gvfs-daemons gvfs-fuse gvfs-backends pulseaudio

echo "=== Limpiando dependencias no utilizadas ==="
apt autoremove -y
apt clean

echo
echo "=== Instalación de LXQt completada correctamente ==="
echo "El entorno gráfico está instalado y el usuario $USER creado."
echo "Usuario: $USER"
echo "Contraseña: $PASSWORD"
echo
echo "Para iniciar el entorno gráfico, debes reiniciar tu sistema."
echo "Puedes ejecutar el comando:"
echo "reboot"
