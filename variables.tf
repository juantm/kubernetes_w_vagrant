variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "k3s_channel" {
  description = "K3s release channel"
  type        = string
  default     = "stable"
}

variable "vagrant_box" {
  description = "Vagrant box to use for VMs"
  type        = string
  default     = "ubuntu/jammy64"
}
