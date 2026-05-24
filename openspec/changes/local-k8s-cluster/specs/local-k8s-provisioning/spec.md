## ADDED Requirements

### Requirement: Automated provisioning of K8s cluster
The system SHALL use Terraform to orchestrate the creation of Vagrant-managed VirtualBox VMs and the installation of K3s on them.

#### Scenario: Successful cluster provisioning
- **WHEN** `terraform apply` is executed
- **THEN** Vagrant VMs are created, and K3s is successfully installed and running on the nodes.

#### Scenario: Node failure during provisioning
- **WHEN** a VM fails to start or K3s fails to install
- **THEN** Terraform reports an error, and the infrastructure state reflects the failure.
