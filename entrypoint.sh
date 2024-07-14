#!/bin/bash

# Start GDM3 and XRDP
systemctl enable --now gdm3
systemctl enable --now xrdp

# Set up sysctl parameters
sysctl -w vm.max_map_count=524288
sysctl -w net.core.wmem_max=8388608
echo "net.core.wmem_max = 8388608" | tee /etc/sysctl.d/xrdp.conf > /dev/null
sysctl --system

# Modify XRDP configuration
sed -i '1 a session required pam_env.so readenv=1 user_readenv=0' /etc/pam.d/xrdp-sesman
sed -i '4 i\export XDG_CURRENT_DESKTOP=debian:GNOME' /etc/xrdp/startwm.sh
sed -i '4 i\export GNOME_SHELL_SESSION_MODE=debian' /etc/xrdp/startwm.sh
sed -i '4 i\export DESKTOP_SESSION=debian' /etc/xrdp/startwm.sh
echo "export XAUTHORITY=${HOME}/.Xauthority" | tee ~/.xsessionrc
echo "export GNOME_SHELL_SESSION_MODE=debian" | tee -a ~/.xsessionrc
echo "export XDG_CONFIG_DIRS=/etc/xdg/xdg-debian:/etc/xdg" | tee -a ~/.xsessionrc

# Restart XRDP
systemctl restart xrdp

# Start JetBrains Toolbox
/opt/jetbrains-toolbox-2.3.2.31487/jetbrains-toolbox

# Start Docker
service docker start

# Keep the container running
tail -f /dev/null
