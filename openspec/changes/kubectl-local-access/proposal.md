## Why

After Terraform provisions the K3s cluster, there is no way to access the cluster from the host machine. The kubeconfig file lives inside the master VM and the API server runs on `192.168.56.10:6443`, which is not directly reachable from the host. Users cannot run `kubectl` locally to manage the cluster.

## What Changes

- Add a Terraform provisioner that copies the kubeconfig from the master VM to the host after provisioning completes
- Update the kubeconfig to point to a local SSH tunnel port (instead of the VM's internal IP) so `kubectl` works from localhost
- Create an SSH tunnel to the K3s API server port (6443) so the host can reach the cluster

## Capabilities

### New Capabilities
- `kubectl-local-access`: Expose the K3s API server to the host via SSH tunnel and provide a locally-configured kubeconfig file

### Modified Capabilities
- (none)

## Impact

- `k3s.tf`: Add provisioner to copy kubeconfig and configure SSH tunnel
- `scripts/`: New script to configure kubeconfig for local access
- No breaking changes to existing cluster provisioning
