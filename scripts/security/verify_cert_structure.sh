#!/bin/bash
set -e

echo "🔍 Verifying certificate structure for Docker mounting..."

CERT_DIR="./wazuh/certs"

echo "1. Checking certificate files exist..."
ls -la $CERT_DIR/

echo ""
echo "2. Testing Docker mount with temporary container..."
docker run --rm -v $(pwd)/wazuh/certs:/test-certs:ro alpine ls -la /test-certs/

echo ""
echo "3. Verifying certificate readability..."
docker run --rm -v $(pwd)/wazuh/certs:/test-certs:ro alpine cat /test-certs/indexer.crt > /dev/null && echo "✅ indexer.crt is readable"
docker run --rm -v $(pwd)/wazuh/certs:/test-certs:ro alpine cat /test-certs/indexer.key > /dev/null && echo "✅ indexer.key is readable"
docker run --rm -v $(pwd)/wazuh/certs:/test-certs:ro alpine cat /test-certs/ca.crt > /dev/null && echo "✅ ca.crt is readable"

echo ""
echo "4. Checking file permissions inside container..."
docker run --rm -v $(pwd)/wazuh/certs:/test-certs:ro alpine stat -c "%a %n" /test-certs/indexer.key
docker run --rm -v $(pwd)/wazuh/certs:/test-certs:ro alpine stat -c "%a %n" /test-certs/indexer.crt

echo "✅ Certificate structure verification completed"
