#!/bin/bash
set -e

echo "🚀 Starting KMED-XDR Full Deployment..."
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# Generate certificates
echo -e "${YELLOW}🔐 Generating SSL certificates...${NC}"
./scripts/security/generate_certs.sh
check_success "Certificate generation"

# Create docker network
echo -e "${YELLOW}🌐 Creating Docker network...${NC}"
docker network create xdr-network || true
check_success "Docker network creation"

# Deploy Wazuh
echo -e "${YELLOW}🛡️ Deploying Wazuh stack...${NC}"
cd wazuh
docker-compose up -d
check_success "Wazuh deployment"
cd ..

# Wait for Wazuh indexer to be ready
echo -e "${YELLOW}⏳ Waiting for Wazuh services to be ready...${NC}"
sleep 60

# Deploy N8N
echo -e "${YELLOW}🤖 Deploying N8N automation...${NC}"
cd n8n
docker-compose up -d
check_success "N8N deployment"
cd ..

# Deploy Monitoring
echo -e "${YELLOW}📊 Deploying monitoring stack...${NC}"
cd monitoring
docker-compose up -d
check_success "Monitoring deployment"
cd ..

# Display deployment status
echo -e "${YELLOW}📋 Deployment Status:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "${GREEN}🎉 KMED-XDR deployment completed!${NC}"
echo ""
echo -e "${YELLOW}📊 Access URLs:${NC}"
echo -e "  Wazuh Dashboard: https://localhost:5601"
echo -e "  N8N Interface: http://localhost:5678"
echo -e "  Grafana: http://localhost:3000"
echo -e "  Prometheus: http://localhost:9090"
echo ""
echo -e "${YELLOW}🔑 Default Credentials:${NC}"
echo -e "  Wazuh: admin / admin"
echo -e "  N8N: admin / your_secure_password_here"
echo -e "  Grafana: admin / admin"
