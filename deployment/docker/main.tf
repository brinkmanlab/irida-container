resource "docker_volume" "user_data" {
  name = "irida-data-${var.instance}"
}

module "galaxy" {
  source   = "github.com/brinkmanlab/galaxy-container.git//destinations/docker"
  #source   = "../../../galaxy-container/destinations/docker"
  instance = var.instance
  galaxy_conf = {
    require_login       = true
    allow_user_creation = false
  }
  image_tag   = "dev"
  admin_users = [var.email]
  email       = var.email
  debug       = var.debug
  host_port = null
  extra_mounts = [
    {
      source = docker_volume.user_data.name
      target = "/irida"
      type = "volume"
      read_only = false
    }
  ]
}

module "admin_user" {
  source         = "github.com/brinkmanlab/galaxy-container.git//modules/bootstrap_admin"
  #source         = "../../../galaxy-container/modules/bootstrap_admin"
  email          = var.email
  galaxy_url     = "http://localhost:${module.galaxy.host_port}"
  master_api_key = module.galaxy.master_api_key
  username       = "admin"
}

provider "galaxy" {
  host    = "http://localhost:${module.galaxy.host_port}"
  apikey = module.admin_user.api_key
}

module "irida" {
  source                 = "../../destinations/docker"
  depends_on             = [module.galaxy]
  instance               = var.instance
  image_tag              = "dev"
  galaxy_api_key         = module.admin_user.api_key
  galaxy_user_email      = var.email
  mail_from              = var.email
  mail_user              = ""
  mail_password          = ""
  base_url               = var.base_url #!= "" ? var.base_url : module.galaxy.endpoint
  #ncbi_user = ""
  #ncbi_password = ""
  debug = var.debug
  host_port = var.host_port
  network = module.galaxy.network
  db_image = "mariadb:10.5.4"
  user_data_volume = docker_volume.user_data
}