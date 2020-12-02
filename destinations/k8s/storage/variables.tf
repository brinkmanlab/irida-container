locals {
  name_suffix  = var.instance == "" ? "" : "-${var.instance}"
}

variable "user_data_volume_name" {
  type        = string
  description = "User data volume name"
}

variable "instance" {
  type        = string
  description = "Unique deployment instance identifier"
}

variable "app_name" {
  type        = string
  description = "Application container name"
}

variable "nfs_server" {
  type        = string
  description = "URL to NFS server containing user data"
}

variable "irida_image" {
  type        = string
  description = "IRIDA application image name"
}

variable "image_tag" {
  type        = string
  description = "Tag for irida-app image"
}

variable "data_dir" {
  type        = string
  description = "Path to user data within container"
}

variable "namespace" {
  description = "Instance of kubernetes_namespace to provision instance resources under"
}