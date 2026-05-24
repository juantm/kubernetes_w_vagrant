## Context

We need a way to provision a Kubernetes cluster locally. Using Terraform as the primary orchestrator, we will manage Vagrant VMs and then install Kubernetes components within them. This ensures a declarative and reproducible environment across developer machines.

## Goals / Non-Goals

**Goals:**
- Automate the creation of multiple VMs via Terraform managing Vagrant.
- Use Terraform to install and configure Kubernetes components (e.g., K3s) within the Vagrant VMs.
- Ensure a reproducible Kubernetes setup (e.g., K3s).
- Enable easy start/stop/destroy cycles via Terraform.

**Non-Goals:**
- Supporting any hypervisor other than VirtualBox.
- Managing production-lag Kubernetes (this is for local dev/test only).
- Complex networking beyond what Vagrant/VirtualBox provides.

## Decisions

- **Hypervisor**: VirtualBox. **Rationale**: Widely available and well-supported by Vagrant.
- **Orchestration Layer**: Terraform. **Rationale**: Terraform will be the primary driver, managing both the Vagrant VM lifecycle and the Kubernetes installation.
- **Provisioning tool**: Terraform + Vagrant. **Rationale**: Terraform will call Vagrant or use a provider/plugin to manage the VMs, then execute provisioning steps to install K3s.
- **Kubernetes Distribution**: K3s. **Rationale**: Lightweight, easy to install, and perfect for local development.
- **Provisioning Layer**: Terraform will manage the end-to-end process from VM creation to K8s readiness.

## Risks / Trade-offs

- **[Risk] Resource Intensive**: Running multiple VMs can consume significant RAM and CPU. → **Mitigation**: Use lightweight K3s and minimal VM footprints.
- **[Risk] Complexity**: Managing two layers of orchestration (Terraform and Vagrant) might be confusing. → **Mitigation**: Clear documentation and a singular `terraform apply` command.
