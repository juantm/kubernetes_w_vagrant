## 1. Create kubeconfig setup script

- [x] 1.1 Create `scripts/setup-kubectl.sh` that copies kubeconfig from master VM and rewrites server URL to `https://127.0.0.1:6443`
- [x] 1.2 Add logic to create `~/.kube/` directory on the host if it doesn't exist

## 2. Add SSH tunnel provisioning

- [x] 2.1 Add `local-exec` provisioner to `null_resource.k3s_master` that starts a background SSH tunnel (`nohup ssh -L 6443:127.0.0.1:6443 ...`) from the host to the master VM
- [x] 2.2 Add port availability check before starting the tunnel (skip or fail if port 6443 is already in use)

## 3. Copy and configure kubeconfig locally

- [x] 3.1 Add `local-exec` provisioner that runs `scripts/setup-kubectl.sh` after the SSH tunnel is established
- [x] 3.2 Ensure the provisioner depends on the master being fully provisioned

## 4. Verify kubectl access

- [x] 4.1 Add `local-exec` provisioner that runs `kubectl --kubeconfig ~/.kube/k3s-config cluster-info` to verify connectivity
- [x] 4.2 Update `scripts/verify-cluster.sh` to use the local kubeconfig
