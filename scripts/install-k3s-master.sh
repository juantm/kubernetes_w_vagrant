#!/bin/bash
set -ex

# Install K3s server (master node)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" INSTALL_K3S_CHANNEL=${INSTALL_K3S_CHANNEL:-stable} sh -

# Wait for K3s to be ready
echo "Waiting for K3s server to start..."
sleep 10

# Configure kubeconfig for root
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config

# Verify installation
kubectl get nodes --kubeconfig /root/.kube/config

echo "K3s master installation complete"
