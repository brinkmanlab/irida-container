locals {
  base_url = var.base_url != "" ? var.base_url : module.galaxy.endpoint
}

variable "cluster_name" {
  type = string
  default = "irida-cluster"
}