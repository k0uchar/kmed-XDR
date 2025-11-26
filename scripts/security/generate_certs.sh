#!/bin/bash
set -e

echo "Generating SSL certificates..."

CERT_DIR="./wazuh/certs"
mkdir -p $CERT_DIR

# Generate CA
openssl genrsa -out $CERT_DIR/ca.key 2048
openssl req -new -x509 -days 3650 -key $CERT_DIR/ca.key -out $CERT_DIR/ca.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=KMED-XDR CA"

# Generate Wazuh indexer certificate
openssl genrsa -out $CERT_DIR/indexer.key 2048
openssl req -new -key $CERT_DIR/indexer.key -out $CERT_DIR/indexer.csr \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=wazuh-indexer"
openssl x509 -req -in $CERT_DIR/indexer.csr -CA $CERT_DIR/ca.crt -CAkey $CERT_DIR/ca.key \
  -CAcreateserial -out $CERT_DIR/indexer.crt -days 3650

# Generate Wazuh dashboard certificate
openssl genrsa -out $CERT_DIR/dashboard.key 2048
openssl req -new -key $CERT_DIR/dashboard.key -out $CERT_DIR/dashboard.csr \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=wazuh-dashboard"
openssl x509 -req -in $CERT_DIR/dashboard.csr -CA $CERT_DIR/ca.crt -CAkey $CERT_DIR/ca.key \
  -CAcreateserial -out $CERT_DIR/dashboard.crt -days 3650

# Set proper permissions
chmod 600 $CERT_DIR/*.key
chmod 644 $CERT_DIR/*.crt

echo " SSL certificates generated in $CERT_DIR"
