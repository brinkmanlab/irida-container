locals {
  base_url = var.base_url
  instance = var.instance == "" ? "default" : var.instance
}

variable "nfs_server" {
  type        = string
  description = "URL to NFS server containing user data"
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "db_subnet_group_name" {
  type = string
}