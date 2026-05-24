#!/bin/bash
set -ex

# Create ~/.kube directory if it doesn't exist
mkdir -p ~/.kube

# Copy kubeconfig from master VM using sudo cat (file is root-owned)
KUBECONFIG_PATH="${KUBECONFIG_PATH:-$HOME/.kube/k3s-config}"
MASTER_HOST="${MASTER_HOST}"
MASTER_PORT="${MASTER_PORT}"
MASTER_USER="${MASTER_USER}"
MASTER_KEY="${MASTER_KEY}"

ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -i "${MASTER_KEY}" \
    -p "${MASTER_PORT}" \
    "${MASTER_USER}@${MASTER_HOST}" \
    'sudo cat /etc/rancher/k3s/k3s.yaml' > "${KUBECONFIG_PATH}"

# Rewrite server URL to point to localhost (SSH tunnel)
sed -i 's|https://[^:]*:6443|https://127.0.0.1:6443|g' "${KUBECONFIG_PATH}"

echo "Kubeconfig copied and configured at ${KUBECONFIG_PATH}"
