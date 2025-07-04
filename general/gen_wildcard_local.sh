#!/usr/bin/env bash
#
# gen_wildcard_local.sh
#
# Creates a self-signed wildcard *.local cert valid for 100 years,
# installs key to /etc/ssl/private and cert to /etc/ssl/certs.
#

set -euo pipefail

# Configuration
CERT_NAME="wildcard_local"
KEY_DIR="/etc/ssl/private"
CRT_DIR="/etc/ssl/certs"
CONFIG_DIR="/etc/ssl/${CERT_NAME}"
DAYS_VALID=36500
RSA_BITS=2048

# Paths
CONF_FILE="${CONFIG_DIR}/${CERT_NAME}.cnf"
KEY_FILE="${KEY_DIR}/${CERT_NAME}.key"
CSR_FILE="${CONFIG_DIR}/${CERT_NAME}.csr"
CRT_FILE="${CRT_DIR}/${CERT_NAME}.crt"

# Ensure running as root
if [[ $(id -u) -ne 0 ]]; then
  echo "ERROR: This script must be run as root (or via sudo)." >&2
  exit 1
fi

# Create config directory
mkdir -p "${CONFIG_DIR}"
chmod 700 "${CONFIG_DIR}"

# Generate OpenSSL config
cat > "${CONF_FILE}" << 'EOF'
[ req ]
default_bits       = {{RSA_BITS}}
prompt             = no
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C  = US
ST = Local
L  = Local Host
O  = Localhost
OU = IT
CN = *.local

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.local
DNS.2 = local
EOF

# Substitute the RSA_BITS if needed (though we leave it in code path)
sed -i "s|{{RSA_BITS}}|${RSA_BITS}|g" "${CONF_FILE}"

# Generate private key and CSR
openssl req -new -nodes \
  -newkey rsa:${RSA_BITS} \
  -keyout "${KEY_FILE}.tmp" \
  -out "${CSR_FILE}" \
  -config "${CONF_FILE}"

# Secure the key and move into place
chmod 600 "${KEY_FILE}.tmp"
mv "${KEY_FILE}.tmp" "${KEY_FILE}"

# Self-sign CSR for 100 years and include SAN
openssl x509 -req \
  -in "${CSR_FILE}" \
  -signkey "${KEY_FILE}" \
  -days "${DAYS_VALID}" \
  -extfile "${CONF_FILE}" \
  -extensions req_ext \
  -out "${CRT_FILE}.tmp"

# Secure the cert and move into place
chmod 644 "${CRT_FILE}.tmp"
mv "${CRT_FILE}.tmp" "${CRT_FILE}"

# Clean up CSR (optional)
rm -f "${CSR_FILE}"

echo "Generated and installed:"
echo "  Private Key: ${KEY_FILE}"
echo "  Certificate: ${CRT_FILE}"
echo "Valid for ${DAYS_VALID} days (~100 years)."
