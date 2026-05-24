# Local Kubernetes Cluster (K3s)

A Terraform-managed Vagrant environment for provisioning a local K3s Kubernetes cluster using VirtualBox VMs.

## Prerequisites

- **Terraform** >= 1.0.0
- **Vagrant**
- **VirtualBox**
- **kubectl** (or use the bundled k3s kubectl)
- **SSH access** to Vagrant VMs (vagrant user)

## Quick Start

```bash
# 1. Initialize Terraform providers
terraform init

# 2. Provision the cluster (creates VMs and installs K3s)
terraform apply

# 3. Verify the cluster
KUBECONFIG=~/.kube/k3s-config kubectl get nodes

# 4. Destroy the cluster when done
terraform destroy
```

## Cluster Topology

| Node        | IP           | RAM  | CPU |
|-------------|-------------|------|-----|
| k3s-master  | 192.168.56.10 | 2048 MB | 2   |
| k3s-worker-1 | 192.168.56.11 | 1024 MB | 1   |
| k3s-worker-2 | 192.168.56.12 | 1024 MB | 1   |

## Configuration

You can customize the cluster via Terraform variables:

```bash
# Change the number of worker nodes
terraform apply -var='node_count=3'

# Use a specific Vagrant box
terraform apply -var='vagrant_box=ubuntu/focal64'

# Use a specific K3s channel
terraform apply -var='k3s_channel=latest'
```

Or set defaults in `terraform.tfvars`:

```hcl
node_count  = 2
vagrant_box = "ubuntu/jammy64"
k3s_channel = "stable"
```

## Files Reference

| File                     | Description                             |
|-------------------------|-----------------------------------------|
| `main.tf`               | Terraform configuration and providers   |
| `provider.tf`            | Vagrant provider configuration         |
| `variables.tf`           | Input variable definitions              |
| `resources.tf`           | Vagrant VM resources                    |
| `networking.tf`          | Network setup provisioning              |
| `k3s.tf`                 | K3s installation provisioning           |
| `scripts/`               | Shell scripts for provisioning          |

## Troubleshooting

- **VMs not starting**: Ensure VirtualBox and Vagrant are properly installed and compatible.
- **K3s install fails**: Check network connectivity and that enough RAM is allocated.
- **Node not joining master**: Verify token matching and network reachability (192.168.56.x).
