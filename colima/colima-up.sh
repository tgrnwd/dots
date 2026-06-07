#!/usr/bin/env bash
set -euo pipefail

# Idempotent local dev cluster setup:
#   colima k3s (gRPC forwarder for UDP) + CoreDNS wildcard DNS +
#   Gateway API + trusted TLS via openssl + Traefik config
#
# Usage: ./colima/colima-up.sh
#
# Prerequisites: colima, kubectl, openssl (installed by bootstrap-tools.sh)
#
# What this creates:
#   Host:
#     ~/.local/share/colima-certs/                    — local CA + TLS cert (openssl)
#     macOS System Keychain                           — CA trust entry
#     /etc/resolver/k8s.local                       — routes *.k8s.local DNS to in-cluster CoreDNS
#     ~/Library/LaunchAgents/homebrew.mxcl.colima.plist — brew service with correct flags
#
#   Cluster (kube-system):
#     HelmChartConfig/traefik        — port remapping + Gateway API provider
#     ConfigMap/coredns-custom       — *.k8s.local → 127.0.0.1 via template plugin
#     Service/coredns-external       — NodePort exposing CoreDNS UDP on port 30053
#
#   Cluster (default):
#     Secret/local-tls               — TLS cert for *.k8s.local
#     Gateway/local-gateway          — HTTPS listener for *.k8s.local
#     HTTPRoute/hello                — routes default-hello.k8s.local → hello:80
#
# Convention: services are reachable at <namespace>-<service>.k8s.local:8443

# --- Helpers ---
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "error: $1 not found"; exit 1; }; }

need brew
need colima
need kubectl
need openssl
need jq
need envsubst
need curl
need dig

CERT_DIR="${HOME}/.local/share/colima-certs"
CA_NAME="Colima Local Dev CA"
GATEWAY_API_VERSION="v1.5.1"
DNS_NODEPORT=30053
LOCAL_DOMAIN="k8s.local"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/manifests"

HOMEBREW_PREFIX="$(brew --prefix)"

# --- Render templatized plist ---
COLIMA_PLIST_TEMPLATE="${SCRIPT_DIR}/homebrew.mxcl.colima.plist"
COLIMA_PLIST="$(mktemp)"
sed -e "s|__HOME__|${HOME}|g" -e "s|__HOMEBREW_PREFIX__|${HOMEBREW_PREFIX}|g" \
  "${COLIMA_PLIST_TEMPLATE}" > "${COLIMA_PLIST}"
trap 'rm -f "${COLIMA_PLIST}"' EXIT

# --- 1. Start Colima via brew services ---
COLIMA_PLIST_ACTIVE="${HOME}/Library/LaunchAgents/homebrew.mxcl.colima.plist"
log "Ensuring Colima is running with correct config"

colima_running() {
  local brew_status
  brew_status="$(brew services info colima --json 2>/dev/null | jq -r '.[0].status')"
  [[ "${brew_status}" == "started" ]] && colima status --json >/dev/null 2>&1
}

plist_matches() {
  if diff -q "${COLIMA_PLIST}" "${COLIMA_PLIST_ACTIVE}" >/dev/null 2>&1; then
    log "Plist matches"
    return 0
  else
    log "Plist changed"
    return 1
  fi
}

if colima_running && plist_matches; then
  log "Nothing to do"
else
  brew services stop colima 2>/dev/null || true
  colima stop 2>/dev/null || true
  brew services start colima --file="${COLIMA_PLIST}"
  log "Colima started via brew services"
fi

# Wait for k8s API to become reachable, then wait for node ready
log "Waiting for Kubernetes API"
for i in $(seq 1 60); do
  kubectl get nodes >/dev/null 2>&1 && break
  sleep 2
done
kubectl wait --for=condition=Ready node --all --timeout=120s

# --- 3. Local CA (idempotent — skip if already exist + trusted) ---
log "Ensuring local CA exists"
mkdir -p "${CERT_DIR}"
if [ ! -f "${CERT_DIR}/ca.pem" ] || [ ! -f "${CERT_DIR}/ca-key.pem" ]; then
  openssl req -x509 -new -nodes -days 3650 \
    -keyout "${CERT_DIR}/ca-key.pem" \
    -out "${CERT_DIR}/ca.pem" \
    -subj "/CN=${CA_NAME}" 2>/dev/null
  log "Created new CA in ${CERT_DIR}"
else
  log "CA already exists in ${CERT_DIR}"
fi

log "Ensuring CA is trusted in macOS keychain"
if ! security find-certificate -c "${CA_NAME}" /Library/Keychains/System.keychain >/dev/null 2>&1; then
  echo "Need sudo to trust CA in System Keychain:"
  sudo security add-trusted-cert -d -r trustRoot \
    -k /Library/Keychains/System.keychain "${CERT_DIR}/ca.pem"
  log "CA trusted"
else
  log "CA already trusted"
fi

# --- 4. Generate TLS cert signed by CA (regen if missing or domain changed) ---
log "Ensuring TLS certificates exist"
EXPECTED_SANS="DNS:*.${LOCAL_DOMAIN}, DNS:${LOCAL_DOMAIN}"
CURRENT_SANS=""
if [ -f "${CERT_DIR}/cert.pem" ] && [ -f "${CERT_DIR}/key.pem" ]; then
  CURRENT_SANS="$(openssl x509 -in "${CERT_DIR}/cert.pem" -noout -ext subjectAltName 2>/dev/null | grep -oE 'DNS:[^,]+' | paste -sd', ' -)"
fi
if [ "${CURRENT_SANS}" = "${EXPECTED_SANS}" ]; then
  log "Certs already exist with correct SANs"
else
  log "Regenerating certs (expected: ${EXPECTED_SANS}, got: ${CURRENT_SANS:-none})"
  openssl req -new -nodes \
    -keyout "${CERT_DIR}/key.pem" \
    -out "${CERT_DIR}/cert.csr" \
    -subj "/CN=*.${LOCAL_DOMAIN}" 2>/dev/null

  openssl x509 -req -days 825 \
    -in "${CERT_DIR}/cert.csr" \
    -CA "${CERT_DIR}/ca.pem" \
    -CAkey "${CERT_DIR}/ca-key.pem" \
    -CAcreateserial \
    -extfile <(printf "subjectAltName=DNS:*.%s,DNS:%s" "${LOCAL_DOMAIN}" "${LOCAL_DOMAIN}") \
    -out "${CERT_DIR}/cert.pem" 2>/dev/null

  rm -f "${CERT_DIR}/cert.csr" "${CERT_DIR}/ca.srl"
  log "Generated new certs in ${CERT_DIR}"
fi

# --- 5. CoreDNS wildcard DNS for *.k8s.local ---
log "Configuring CoreDNS for *.${LOCAL_DOMAIN}"
export LOCAL_DOMAIN DNS_NODEPORT
envsubst '${LOCAL_DOMAIN}' < "${MANIFESTS_DIR}/coredns-custom.yaml" | kubectl apply -f -
envsubst '${DNS_NODEPORT}' < "${MANIFESTS_DIR}/coredns-external.yaml" | kubectl apply -f -

# Restart CoreDNS to pick up the custom config
kubectl rollout restart deploy/coredns -n kube-system >/dev/null 2>&1
kubectl rollout status deploy/coredns -n kube-system --timeout=30s >/dev/null 2>&1
log "CoreDNS configured and restarted"

# --- 6. macOS resolver for k8s.local → CoreDNS via NodePort ---
RESOLVER_FILE="/etc/resolver/${LOCAL_DOMAIN}"
if [ ! -f "${RESOLVER_FILE}" ] || ! grep -q "port ${DNS_NODEPORT}" "${RESOLVER_FILE}" 2>/dev/null; then
  log "Creating ${RESOLVER_FILE} (routes *.${LOCAL_DOMAIN} to in-cluster CoreDNS)"
  sudo mkdir -p /etc/resolver
  sudo tee "${RESOLVER_FILE}" >/dev/null <<EOF
nameserver 127.0.0.1
port ${DNS_NODEPORT}
EOF
  log "Resolver configured"
else
  log "Resolver already configured"
fi

# --- 7. Gateway API CRDs ---
log "Applying Gateway API CRDs ${GATEWAY_API_VERSION}"
kubectl apply -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml" >/dev/null 2>&1

# --- 8. TLS Secret (idempotent via dry-run + apply) ---
log "Ensuring TLS secret"
kubectl create secret tls local-tls \
  --cert="${CERT_DIR}/cert.pem" \
  --key="${CERT_DIR}/key.pem" \
  --dry-run=client -o yaml | kubectl apply -f - >/dev/null

# --- 9. Traefik HelmChartConfig (Gateway API provider + port remapping) ---
log "Configuring Traefik"
kubectl apply -f "${MANIFESTS_DIR}/traefik-config.yaml"

# Wait for Traefik to pick up the gateway provider
log "Waiting for Traefik rollout"
kubectl rollout status deploy/traefik -n kube-system --timeout=60s >/dev/null 2>&1

# --- 10. Gateway ---
log "Applying Gateway"
envsubst '${LOCAL_DOMAIN}' < "${MANIFESTS_DIR}/gateway.yaml" | kubectl apply -f -

# --- 11. Verify ---
log "Verifying DNS resolution"
sleep 2
if dig +short test.${LOCAL_DOMAIN} @127.0.0.1 -p ${DNS_NODEPORT} 2>/dev/null | grep -q '127.0.0.1'; then
  log "DNS working: *.${LOCAL_DOMAIN} → 127.0.0.1"
else
  log "Warning: DNS not resolving yet — CoreDNS may still be restarting"
fi

log "Verifying HTTPS"
VERIFY_HOST="test.${LOCAL_DOMAIN}"
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' --resolve "${VERIFY_HOST}:8443:127.0.0.1" "https://${VERIFY_HOST}:8443" 2>/dev/null || echo "000")
if [ "${HTTP_CODE}" = "404" ]; then
  log "Trusted HTTPS working on *.${LOCAL_DOMAIN}:8443 (Traefik responded with 404 — no routes yet)"
else
  log "Warning: got HTTP ${HTTP_CODE} — Traefik may still be restarting, try again in a few seconds"
fi

log "Done. Run 'tgdots help colima' for usage details."
