resource "vagrant_vm" "k3s_master" {
  vagrantfile_dir = "vagrantfiles/master"
}

resource "vagrant_vm" "k3s_worker" {
  count           = var.node_count
  vagrantfile_dir = "vagrantfiles/worker-${count.index}"
}
