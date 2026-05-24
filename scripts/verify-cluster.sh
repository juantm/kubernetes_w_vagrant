#!/bin/bash
set -ex

echo "===== Local K8s Cluster Verification Script ====="

# Step 1: Check if kubeconfig exists
echo "[1/4] Checking kubeconfig..."
if [ ! -f ~/.kube/k3s-config ]; then
  echo "ERROR: ~/.kube/k3s-config not found. Run 'terraform apply' first."
  exit 1
fi

# Step 2: Check SSH tunnel
echo "[2/4] Checking SSH tunnel..."
if ss -tln 2>/dev/null | grep -q ':6443 '; then
  echo "SSH tunnel is active on port 6443"
else
  echo "WARNING: SSH tunnel not detected on port 6443. kubectl may not work."
fi

# Step 3: Verify cluster connectivity
echo "[3/4] Verifying cluster connectivity..."
kubectl --kubeconfig ~/.kube/k3s-config cluster-info

# Step 4: Check node and pod status
echo "[4/4] Checking cluster status..."
kubectl --kubeconfig ~/.kube/k3s-config get nodes
kubectl --kubeconfig ~/.kube/k3s-config get pods -n kube-system

echo ""
echo "===== Verification Complete ====="
echo "Cluster is ready!"
echo "Use: kubectl --kubeconfig ~/.kube/k3s-config <command>"
