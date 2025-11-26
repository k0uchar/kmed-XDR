#!/bin/bash
set -e

echo "Installing Docker and prerequisites..."

# Update system
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Remove old versions (safely)
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker compose version

echo "✅ Docker installation completed successfully!"
echo "⚠️ Log out and log in again to apply docker group changes."
