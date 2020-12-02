locals {
  base_url = var.base_url
  instance = var.instance == "" ? "default" : var.instance
}

variable "claim_name" {
  type        = string
  description = "Name of user data PVC"
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "db_subnet_group_name" {
  type = string
}

variable "namespace" {
  default = null
  description = "Instance of kubernetes_namespace to provision instance resources under"
}