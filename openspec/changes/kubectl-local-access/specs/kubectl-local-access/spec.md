## ADDED Requirements

### Requirement: kubeconfig file copied to host
After provisioning completes, the K3s kubeconfig file SHALL be copied from the master VM to the host machine at `~/.kube/k3s-config`.

#### Scenario: kubeconfig exists after provisioning
- **WHEN** terraform apply completes successfully
- **THEN** the file `~/.kube/k3s-config` exists on the host machine

#### Scenario: kubeconfig contains correct cluster info
- **WHEN** the kubeconfig file is read
- **THEN** the server URL is `https://127.0.0.1:6443`

### Requirement: SSH tunnel to API server
After provisioning completes, an SSH tunnel SHALL be established from localhost:6443 to the master VM's K3s API server on port 6443.

#### Scenario: tunnel is running after provisioning
- **WHEN** terraform apply completes successfully
- **THEN** an SSH process is running that forwards localhost:6443 to the master VM

#### Scenario: kubectl can reach the API server
- **WHEN** the user runs `kubectl --kubeconfig ~/.kube/k3s-config cluster-info`
- **THEN** the command returns cluster information without connection errors

### Requirement: kubectl works with kubeconfig
The user SHALL be able to run `kubectl` commands against the cluster using the generated kubeconfig.

#### Scenario: get nodes returns cluster nodes
- **WHEN** the user runs `kubectl --kubeconfig ~/.kube/k3s-config get nodes`
- **THEN** the output lists the master and worker nodes with Ready status
