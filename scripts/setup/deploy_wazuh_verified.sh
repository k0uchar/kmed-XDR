#!/bin/bash
set -e

echo "🚀 Deploying Wazuh with Verification..."

# Verify certificates first
chmod +x scripts/security/verify_cert_structure.sh
./scripts/security/verify_cert_structure.sh

# Create network
docker network create xdr-network || true

# Use fixed docker-compose
cp wazuh/docker-compose-fixed.yml wazuh/docker-compose.yml

cd wazuh

echo "1. Starting Wazuh Indexer..."
docker-compose up -d wazuh-indexer

echo "2. Waiting for indexer to initialize (this can take 3-5 minutes)..."
for i in {1..60}; do
    # Check if container is running
    if ! docker ps | grep -q "wazuh-indexer"; then
        echo "❌ Wazuh Indexer container stopped unexpectedly"
        docker logs wazuh-wazuh-indexer-1
        exit 1
    fi
    
    # Check for success
    if docker logs wazuh-wazuh-indexer-1 2>&1 | grep -q "Node started"; then
        echo "✅ Wazuh Indexer started successfully after $((i*5)) seconds"
        break
    fi
    
    # Check for certificate errors
    if docker logs wazuh-wazuh-indexer-1 2>&1 | grep -q "Unable to read.*certs"; then
        echo "❌ Certificate error detected:"
        docker logs wazuh-wazuh-indexer-1 | grep "Unable to read"
        echo "Checking mounted files in container..."
        docker exec wazuh-wazuh-indexer-1 ls -la /usr/share/wazuh-indexer/certs/ || echo "Cannot access certs directory"
        exit 1
    fi
    
    echo "⏳ Waiting for Wazuh Indexer... ($i/60 - $((i*5)) seconds)"
    sleep 5
done

# Check if indexer is healthy
echo "3. Checking indexer health..."
if curl -k -s https://localhost:9200 > /dev/null; then
    echo "✅ Wazuh Indexer is responding"
else
    echo "❌ Wazuh Indexer not responding, checking logs..."
    docker logs wazuh-wazuh-indexer-1 --tail 20
    exit 1
fi

echo "4. Starting remaining services..."
docker-compose up -d

echo "5. Final status check..."
sleep 30
docker-compose ps

echo "🎉 Wazuh deployment completed!"
cd ..
