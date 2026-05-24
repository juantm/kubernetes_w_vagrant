resource "null_resource" "k3s_master" {
  connection {
    type        = "ssh"
    host        = vagrant_vm.k3s_master.ssh_config[0].host
    port        = vagrant_vm.k3s_master.ssh_config[0].port
    user        = vagrant_vm.k3s_master.ssh_config[0].user
    private_key = vagrant_vm.k3s_master.ssh_config[0].private_key
  }

  provisioner "file" {
    source      = "scripts/install-k3s-master.sh"
    destination = "/tmp/install-k3s-master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-k3s-master.sh",
      "INSTALL_K3S_CHANNEL=${var.k3s_channel} sudo bash /tmp/install-k3s-master.sh",
      "sleep 5",
      "sudo cat /var/lib/rancher/k3s/server/node-token"
    ]
  }

  # Write the master's private key to a file for local-exec SSH commands
  provisioner "local-exec" {
    command = <<-EOT
cat > .ssh-master-key << 'KEYEOF'
${vagrant_vm.k3s_master.ssh_config[0].private_key}
KEYEOF
chmod 600 .ssh-master-key
EOT
  }

  # Fetch the node token from the master and save it locally for workers to use
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .ssh-master-key -p ${vagrant_vm.k3s_master.ssh_config[0].port} ${vagrant_vm.k3s_master.ssh_config[0].user}@${vagrant_vm.k3s_master.ssh_config[0].host} 'sudo cat /var/lib/rancher/k3s/server/node-token' > .k3s-node-token"
  }

  depends_on = [null_resource.network_config_master]
}

# Setup local kubectl access: SSH tunnel + kubeconfig
resource "null_resource" "kubectl_setup" {
  # Check port availability and start SSH tunnel to K3s API server
  provisioner "local-exec" {
    command = "if ss -tln 2>/dev/null | grep -q ':6443 ' || netstat -tln 2>/dev/null | grep -q ':6443 '; then echo 'Port 6443 already in use, skipping tunnel setup'; else nohup ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .ssh-master-key -p ${vagrant_vm.k3s_master.ssh_config[0].port} -L 6443:127.0.0.1:6443 -N ${vagrant_vm.k3s_master.ssh_config[0].user}@${vagrant_vm.k3s_master.ssh_config[0].host} > /dev/null 2>&1 & echo $! > .k3s-tunnel-pid; echo 'SSH tunnel started (PID: '$(cat .k3s-tunnel-pid)')'; fi"
  }

  # Copy kubeconfig from master VM and configure for local access
  provisioner "local-exec" {
    command = "sleep 3 && MASTER_HOST=${vagrant_vm.k3s_master.ssh_config[0].host} MASTER_PORT=${vagrant_vm.k3s_master.ssh_config[0].port} MASTER_USER=${vagrant_vm.k3s_master.ssh_config[0].user} MASTER_KEY=.ssh-master-key bash scripts/setup-kubectl.sh"
  }

  # Verify kubectl connectivity
  provisioner "local-exec" {
    command = "sleep 5 && kubectl --kubeconfig ~/.kube/k3s-config cluster-info"
  }

  depends_on = [null_resource.k3s_master]
}

resource "null_resource" "k3s_worker" {
  count = var.node_count

  connection {
    type        = "ssh"
    host        = vagrant_vm.k3s_worker[count.index].ssh_config[0].host
    port        = vagrant_vm.k3s_worker[count.index].ssh_config[0].port
    user        = vagrant_vm.k3s_worker[count.index].ssh_config[0].user
    private_key = vagrant_vm.k3s_worker[count.index].ssh_config[0].private_key
  }

  provisioner "file" {
    source      = "scripts/install-k3s-worker.sh"
    destination = "/tmp/install-k3s-worker.sh"
  }

  # Write the worker's private key to a file for local-exec SSH commands
  provisioner "local-exec" {
    command = <<-EOT
cat > .ssh-worker-${count.index}-key << 'KEYEOF'
${vagrant_vm.k3s_worker[count.index].ssh_config[0].private_key}
KEYEOF
chmod 600 .ssh-worker-${count.index}-key
EOT
  }

  # Pipe the master node token from the local file to the worker VM
  provisioner "local-exec" {
    command = "cat .k3s-node-token | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .ssh-worker-${count.index}-key -p ${vagrant_vm.k3s_worker[count.index].ssh_config[0].port} ${vagrant_vm.k3s_worker[count.index].ssh_config[0].user}@${vagrant_vm.k3s_worker[count.index].ssh_config[0].host} 'cat | sudo tee /tmp/k3s-node-token'"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for master to be ready...' && sleep 10 && K3S_TOKEN=$(cat /tmp/k3s-node-token) && INSTALL_K3S_CHANNEL=${var.k3s_channel} sudo env K3S_URL=https://192.168.56.10:6443 K3S_TOKEN=$K3S_TOKEN bash /tmp/install-k3s-worker.sh"
    ]
  }

  depends_on = [null_resource.k3s_master, null_resource.network_config_worker]
}
