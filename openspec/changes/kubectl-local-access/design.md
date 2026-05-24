## Context

The K3s cluster runs inside Vagrant VMs on the `192.168.56.x` private network. The API server listens on `192.168.56.10:6443` inside the master VM. The host machine cannot reach this address directly. The kubeconfig file is stored at `/etc/rancher/k3s/k3s.yaml` inside the master VM and references `https://127.0.0.1:6443`.

## Goals / Non-Goals

**Goals:**
- After `terraform apply`, the user can run `kubectl` on the host to manage the cluster
- kubeconfig is automatically copied and configured for local access
- SSH tunnel to the API server is established automatically

**Non-Goals:**
- Managing SSH tunnel lifecycle outside of Terraform (e.g., systemd service)
- Multi-user access or RBAC configuration

## Decisions

- **SSH tunnel via local-exec**: Use `ssh -L` to forward localhost:6443 to the master VM's 6443. This avoids installing extra tools and uses the existing Vagrant SSH key.
- **kubeconfig copy via provisioner**: Copy the kubeconfig file during provisioning and rewrite the server URL to `https://127.0.0.1:6443` so it works with the SSH tunnel.
- **Tunnel in background via nohup**: Start the SSH tunnel as a background process so it persists after Terraform finishes.

## Risks / Trade-offs

- [SSH tunnel process dies] → The tunnel is a background process with no health check. If it dies, kubectl stops working. Mitigation: document manual restart in README.
- [Port 6443 already in use on host] → If the host has a local Kubernetes or Docker desktop running, port 6443 may be occupied. Mitigation: check port availability before starting tunnel.
