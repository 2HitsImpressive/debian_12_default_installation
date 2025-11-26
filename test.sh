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

echo "=== Modificando panel.conf global de LXQt ==="

PANEL_GLOBAL="/etc/xdg/lxqt/panel.conf"

# Cambiar tamaño de iconos del panel (20 → 30)
sed -i 's/iconsize=20/iconsize=30/' "$PANEL_GLOBAL"

# Cambiar alto del panel (panelSize 32 → 40)
sed -i 's/panelSize=32/panelSize=40/' "$PANEL_GLOBAL"

# Eliminar widget de dispositivos removibles (mount)
sed -i '/plugin=mount/,/^\[/d' "$PANEL_GLOBAL"

# Eliminar widget de volumen
sed -i '/plugin=volume/,/^\[/d' "$PANEL_GLOBAL"

# Eliminar widget statusnotifier
sed -i '/plugin=statusnotifier/,/^\[/d' "$PANEL_GLOBAL"

echo "=== Cambios aplicados a /etc/xdg/lxqt/panel.conf ==="
echo "=== Todos los usuarios nuevos heredarán esta configuración ==="


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
#apt remove -y lxqt-powermanagement qlipper lxqt-notificationd lxqt-runner xscreensaver xscreensaver-data xscreensaver-data-extra xscreensaver-gl gvfs gvfs-daemons gvfs-fuse gvfs-backends pulseaudio avahi-daemon avahi-utils at-spi2-core at-spi2-common 
apt remove --purge -y \
    lxqt-powermanagement \
    qlipper \
    lxqt-notificationd \
    lxqt-runner \
    xscreensaver \
    xscreensaver-data \
    xscreensaver-data-extra \
    xscreensaver-gl \
    pulseaudio \
    pulseaudio-utils \
    gvfs \
    gvfs-daemons \
    gvfs-fuse \
    gvfs-backends \
    avahi-daemon \
    avahi-utils \
    system-config-printer \
    printer-driver-* \
    cups* \
    upower \
    #at-spi2-core \
    at-spi2-common

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
