#!/bin/bash
set -e

echo "Configuring Docker environment..."

# Create docker network for XDR components
docker network create xdr-network || true

# Configure Docker daemon for better performance
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart docker
sudo systemctl restart docker
sudo systemctl enable docker

echo "Docker configuration completed!"
