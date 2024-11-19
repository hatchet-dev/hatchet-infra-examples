#!/bin/bash
# This scripts generates test keys and certificates for the sample.

# env name is required
if [ -z "$ENV_NAME" ]; then
    echo "Please set ENV_NAME variable"
    exit 1
fi

# domain name is required
if [ -z "$DOMAIN_NAME" ]; then
    echo "Please set DOMAIN_NAME variable"
    exit 1
fi

CERTS_DIR=./$ENV_NAME
mkdir -p $CERTS_DIR

cat > $CERTS_DIR/cluster-cert.conf <<EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[dn]
C = US
ST = WA
O = Hatchet Technologies, Inc.
CN = $DOMAIN_NAME
[req_ext]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN_NAME
EOF

cat > $CERTS_DIR/worker-client-cert.conf <<EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[dn]
C = US
ST = WA
O = Hatchet Technologies, Inc.
CN = worker
[req_ext]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN_NAME
EOF

# Generate a private key and a certificate for a test certificate authority
openssl genrsa -out $CERTS_DIR/ca.key 4096
openssl req -new -x509 -key $CERTS_DIR/ca.key -sha256 -subj "/C=US/ST=WA/O=Hatchet Technologies, Inc./CN=$DOMAIN_NAME" -days 365 -out $CERTS_DIR/ca.cert

# Generate a private key and a certificate for the cluster
openssl req -newkey rsa:4096 -nodes -keyout "$CERTS_DIR/cluster.key" -out "$CERTS_DIR/cluster.csr" -config $CERTS_DIR/cluster-cert.conf
openssl x509 -req -in $CERTS_DIR/cluster.csr -CA $CERTS_DIR/ca.cert -CAkey $CERTS_DIR/ca.key -CAcreateserial -out $CERTS_DIR/cluster.pem -days 365 -sha256 -extfile $CERTS_DIR/cluster-cert.conf -extensions req_ext

# Generate a private key and a certificate for worker client
openssl req -newkey rsa:4096 -nodes -keyout "$CERTS_DIR/client-worker.key" -out "$CERTS_DIR/client-worker.csr" -config $CERTS_DIR/worker-client-cert.conf
openssl x509 -req -in $CERTS_DIR/client-worker.csr -CA $CERTS_DIR/ca.cert -CAkey $CERTS_DIR/ca.key -CAcreateserial -out $CERTS_DIR/client-worker.pem -days 365 -sha256 -extfile $CERTS_DIR/worker-client-cert.conf -extensions req_ext