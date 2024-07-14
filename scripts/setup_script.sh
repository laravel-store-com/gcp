#!/bin/bash

# Update and upgrade the system
sudo apt-get update
sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y php composer mc git htop make rsync telnet gnome-core gnome-session gdm3 gnome-tweaks xrdp wget gpg ca-certificates curl apt-transport-https preload

# Stop and disable Apache2
sudo systemctl stop apache2
sudo systemctl disable apache2

# Enable and start GDM3 and XRDP
sudo systemctl enable --now gdm3
sudo systemctl enable --now xrdp

# Configuration for XRDP
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w net.core.wmem_max=8388608
echo "net.core.wmem_max = 8388608" | sudo tee /etc/sysctl.d/xrdp.conf > /dev/null
sudo sysctl --system
sudo sed -i '1 a session required pam_env.so readenv=1 user_readenv=0' /etc/pam.d/xrdp-sesman
sudo sed -i '4 i\export XDG_CURRENT_DESKTOP=debian:GNOME' /etc/xrdp/startwm.sh
sudo sed -i '4 i\export GNOME_SHELL_SESSION_MODE=debian' /etc/xrdp/startwm.sh
sudo sed -i '4 i\export DESKTOP_SESSION=debian' /etc/xrdp/startwm.sh
echo "export XAUTHORITY=${HOME}/.Xauthority" | tee ~/.xsessionrc
echo "export GNOME_SHELL_SESSION_MODE=debian" | tee -a ~/.xsessionrc
echo "export XDG_CONFIG_DIRS=/etc/xdg/xdg-debian:/etc/xdg" | tee -a ~/.xsessionrc
sudo systemctl restart xrdp

# Install JetBrains Toolbox
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.2.31487.tar.gz
sudo tar -xzf jetbrains-toolbox-2.3.2.31487.tar.gz -C /opt

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb

# Install Visual Studio Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code
sudo apt remove -y gnome-software

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Clean up
sudo apt-get autoremove -y
sudo apt-get clean

# Reboot the system
sudo init 6

# Create and configure users
for user in aktivdigital junior senior test; do
    sudo useradd -m -s /bin/bash $user
    echo "${user}:Adm123#" | sudo chpasswd
    sudo usermod -aG docker $user
    sudo usermod -aG sudo $user
    sudo su $user -c '/opt/jetbrains-toolbox-2.3.2.31487/jetbrains-toolbox'
done

# Set root password
echo 'root:Adm123#' | sudo chpasswd
