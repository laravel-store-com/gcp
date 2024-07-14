# Use an official Debian as a parent image
FROM debian:12-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y php composer mc git htop make rsync telnet gnome-core gnome-session gdm3 gnome-tweaks xrdp wget gpg ca-certificates curl apt-transport-https preload && \
    apt-get install -y sudo && \
    apt-get clean

# Install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# Install Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list && \
    apt update && apt install -y code && apt remove -y gnome-software && rm -f packages.microsoft.gpg

# Install JetBrains Toolbox
RUN wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.2.31487.tar.gz && \
    tar -xzf jetbrains-toolbox-2.3.2.31487.tar.gz -C /opt && \
    rm jetbrains-toolbox-2.3.2.31487.tar.gz

# Install Docker
RUN apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Setup SSH and other configurations
RUN echo 'root:Adm123#' | chpasswd

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint script executable
RUN chmod +x /entrypoint.sh

# Expose necessary ports
EXPOSE 3389

# Start services and run entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
