locals {
  base_url = var.base_url != "" ? var.base_url : kubernetes_service.irida.load_balancer_ingress.0.hostname
  instance = var.instance == "" ? "default" : var.instance
}

variable "nfs_server" {
  type        = string
  description = "URL to NFS server containing user data"
}