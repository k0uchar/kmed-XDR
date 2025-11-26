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

# Check for docker-compose or docker compose
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo -e "${RED}❌ Neither docker-compose nor docker compose is available${NC}"
        exit 1
    fi
}

DOCKER_COMPOSE_CMD=$(check_docker_compose)
echo -e "${YELLOW}Using: $DOCKER_COMPOSE_CMD${NC}"

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
$DOCKER_COMPOSE_CMD up -d
check_success "Wazuh deployment"
cd ..

# Wait for Wazuh indexer to be ready
echo -e "${YELLOW}⏳ Waiting for Wazuh services to be ready...${NC}"
sleep 30

# Check if Wazuh indexer is healthy
echo -e "${YELLOW}🔍 Checking Wazuh indexer health...${NC}"
until curl -k -s -f https://localhost:9200; do
    echo "Waiting for Wazuh indexer..."
    sleep 10
done

# Deploy N8N
echo -e "${YELLOW}🤖 Deploying N8N automation...${NC}"
cd n8n
$DOCKER_COMPOSE_CMD up -d
check_success "N8N deployment"
cd ..

# Deploy Monitoring
echo -e "${YELLOW}📊 Deploying monitoring stack...${NC}"
cd monitoring
$DOCKER_COMPOSE_CMD up -d
check_success "Monitoring deployment"
cd ..

# Wait for all services to start
echo -e "${YELLOW}⏳ Finalizing deployment...${NC}"
sleep 30

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
echo ""
echo -e "${YELLOW}⚠️  Important: Change default passwords after first login!${NC}"
