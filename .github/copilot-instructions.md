# Copilot Instructions

## Project Overview

Terraform-managed Vagrant environment that provisions a local K3s Kubernetes cluster on VirtualBox. One master node and configurable worker nodes, all on the `192.168.56.x` private network. Includes automatic local kubectl access via an SSH tunnel on port 6443.

## Providers & Dependencies

- **Terraform** >= 1.0.0
- **bmatcuk/vagrant** (~> 4.0.0) — creates and manages VMs from pre-written Vagrantfiles
- **hashicorp/null** (~> 3.0) — runs remote provisioning scripts via SSH

## Architecture

### File Structure

| File | Role |
|---|---|
| `main.tf` | Terraform version and provider requirements |
| `provider.tf` | Vagrant provider block |
| `variables.tf` | Input variables (`node_count`, `k3s_channel`, `vagrant_box`) |
| `resources.tf` | `vagrant_vm` resources pointing to directories under `vagrantfiles/` |
| `networking.tf` | `null_resource` that configures `/etc/hosts` and IP forwarding on each VM |
| `k3s.tf` | K3s install, token exchange, worker joining, and local kubectl setup |
| `scripts/` | Shell scripts uploaded to VMs for provisioning |
| `vagrantfiles/` | Pre-generated Vagrantfiles (one per VM) |
| `Vagrantfile.template` | Reference template showing variable interpolation pattern |

### Provisioning Pipeline

Executes in this dependency order:

1. **`resources.tf`** — `vagrant_vm.k3s_master` and `vagrant_vm.k3s_worker` (count-based) bring up VMs from Vagrantfiles in `vagrantfiles/master/` and `vagrantfiles/worker-N/`.
2. **`networking.tf`** — `null_resource.network_config_master` and `null_resource.network_config_worker` SSH into each VM, upload and run `scripts/setup-networking.sh` (writes DNS entries to `/etc/hosts`, enables `net.ipv4.ip_forward`).
3. **`k3s.tf`** — Four resources in sequence:
   - `null_resource.k3s_master` installs K3s server, then fetches the node token via `local-exec` SSH and saves it to `.k3s-node-token`.
   - `null_resource.kubectl_setup` starts an SSH tunnel (`localhost:6443` → master), copies and patches kubeconfig to `~/.kube/k3s-config`, verifies connectivity.
   - `null_resource.k3s_worker` (count-based) pipes the token from `.k3s-node-token` into each worker via SSH, then runs `scripts/install-k3s-worker.sh` to join the cluster.

### Token Flow

The K3s node token cannot be passed directly through Terraform interpolation. Instead it flows:
```
master VM → local-exec SSH → .k3s-node-token (local file) → SSH pipe → worker VM
```

### Local kubectl Access

`null_resource.kubectl_setup` creates an SSH tunnel from `localhost:6443` to the master's K3s API server and writes a kubeconfig to `~/.kube/k3s-config` with the server URL rewritten to `127.0.0.1:6443`. The tunnel PID is saved to `.k3s-tunnel-pid`. After provisioning, use:
```bash
kubectl --kubeconfig ~/.kube/k3s-config <command>
```

## Key Conventions

- **Vagrantfiles are pre-generated**, not embedded in Terraform. `resources.tf` references `vagrantfile_dir` paths. When adding/changing VM specs, edit the files under `vagrantfiles/` (or regenerate from `Vagrantfile.template`).
- **Worker count**: Driven by `var.node_count` (default: 2). Worker IPs increment from `192.168.56.11`. Any network topology change must be consistent across `vagrantfiles/`, `scripts/setup-networking.sh`, and any hardcoded IP references.
- **K3s channel**: Controlled by `var.k3s_channel` (default: `stable`). Passed as `INSTALL_K3S_CHANNEL` env var to provisioning scripts.
- **SSH connections**: `null_resource` blocks use `vagrant_vm.*.ssh_config[0]` attributes (host, port, user, private_key) for connectivity — not `.ssh_host` / `.ssh_private_key`.
- **Provisioning scripts** use `set -ex` (fail-fast) and are uploaded to `/tmp` then executed with `sudo bash`.
- **OpenSpec workflow**: This repo uses OpenSpec (`openspec/`). Use the openspec skills for proposing, exploring, and applying changes.

## Pitfalls (learned from debugging)

- **`ssh_config[0].private_key` returns raw PEM content**, not a file path. You cannot pass it to `ssh -i` in a `local-exec` command — write it to a file first (as done in `k3s.tf` with `.ssh-master-key` / `.ssh-worker-N-key`).
- **`sudo` strips environment variables**. When passing `K3S_URL` or `K3S_TOKEN` to a `sudo` command, use `sudo env VAR=value ...` (as done for worker install in `k3s.tf`).
- **`~` does not expand inside double-quoted parameter defaults** (`"${VAR:-~/.kube/k3s-config}"` keeps `~` literal). Use `$HOME` instead (as done in `scripts/setup-kubectl.sh`).
- **`/etc/rancher/k3s/k3s.yaml` is root-owned**. The `vagrant` user cannot `scp` it — use `ssh ... 'sudo cat ...' > local_file` instead (as done in `scripts/setup-kubectl.sh`).

## Commands

```bash
terraform init           # Initialize providers
terraform plan           # Preview changes
terraform apply          # Provision the cluster
terraform destroy        # Tear down the cluster
terraform validate       # Check HCL syntax (no linters/tests configured)
bash scripts/verify-cluster.sh   # Manual cluster health check
kubectl --kubeconfig ~/.kube/k3s-config get nodes   # Query cluster
```
