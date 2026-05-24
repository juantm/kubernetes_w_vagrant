resource "null_resource" "network_config_master" {
  connection {
    type        = "ssh"
    host        = vagrant_vm.k3s_master.ssh_config[0].host
    port        = vagrant_vm.k3s_master.ssh_config[0].port
    user        = vagrant_vm.k3s_master.ssh_config[0].user
    private_key = vagrant_vm.k3s_master.ssh_config[0].private_key
  }

  provisioner "file" {
    source      = "scripts/setup-networking.sh"
    destination = "/tmp/setup-networking.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-networking.sh",
      "NODE_COUNT=${var.node_count} sudo bash /tmp/setup-networking.sh"
    ]
  }

  depends_on = [vagrant_vm.k3s_master]
}

resource "null_resource" "network_config_worker" {
  count = var.node_count

  connection {
    type        = "ssh"
    host        = vagrant_vm.k3s_worker[count.index].ssh_config[0].host
    port        = vagrant_vm.k3s_worker[count.index].ssh_config[0].port
    user        = vagrant_vm.k3s_worker[count.index].ssh_config[0].user
    private_key = vagrant_vm.k3s_worker[count.index].ssh_config[0].private_key
  }

  provisioner "file" {
    source      = "scripts/setup-networking.sh"
    destination = "/tmp/setup-networking.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-networking.sh",
      "NODE_COUNT=${var.node_count} sudo bash /tmp/setup-networking.sh"
    ]
  }

  depends_on = [vagrant_vm.k3s_worker]
}
