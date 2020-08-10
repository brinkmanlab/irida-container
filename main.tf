locals {
  ansible                 = yamldecode(file("${path.root}/vars.yml"))
  ansible_galaxy          = yamldecode(file("${path.root}/galaxy/vars.yml"))
  object_store_access_key = var.object_store_access_key #!= "" ? var.object_store_access_key : random_string.object_store_access_key.result
  object_store_secret_key = var.object_store_secret_key #!= "" ? var.object_store_secret_key : random_password.object_store_secret_key.result
  instance = ""
  name_suffix             = local.instance != "" ? "-${local.instance}" : ""
}

## Docker Config

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

## AWS Config

provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}

## General Config

module "irida" {
  source                  = "./destinations/aws"
  image_tag               = var.image_tag
  instance                = local.instance
  name_suffix             = local.name_suffix
  galaxy_api_key          = ""
  galaxy_user_email       = ""
  mail_from               = ""
  mail_password           = ""
  mail_user               = ""
  object_store_access_key = local.object_store_access_key
  object_store_secret_key = local.object_store_secret_key
  app_name                = local.ansible.containers.app.name
  db_name                 = local.ansible.containers.db.name
  data_dir                = local.ansible.paths.data
  user_data_volume_name   = local.ansible.volumes.user_data.name
  db_data_volume_name     = local.ansible.volumes.db_data.name
}