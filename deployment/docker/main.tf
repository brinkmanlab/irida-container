resource "docker_volume" "user_data" {
  name = "irida-data-${var.instance}"
}

module "galaxy" {
  #source   = "github.com/brinkmanlab/galaxy-container.git//destinations/docker"
  source   = "../../../galaxy-container/destinations/docker"
  instance = var.instance
  galaxy_conf = {
    require_login       = true
    allow_user_creation = false
  }
  image_tag   = "latest"
  admin_users = [var.email]
  email       = var.email
  debug       = var.debug
  extra_mounts = [
    {
      source = docker_volume.user_data.name
      target = "/irida"
      type = "volume"
      read_only = false
    }
  ]
  extra_job_mounts = ["${docker_volume.user_data.name}:/irida:ro"]
  docker_gid = var.docker_gid
  docker_socket_path = var.docker_socket_path
  tool_mappings = yamldecode(file("../../tool_mapping.yml"))
}

module "admin_user" {
  #source         = "github.com/brinkmanlab/galaxy-container.git//modules/bootstrap_admin"
  source         = "../../../galaxy-container/modules/bootstrap_admin"
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
  image_tag              = "latest"
  galaxy_api_key         = module.admin_user.api_key
  galaxy_user_email      = var.email
  base_url               = var.base_url #!= "" ? var.base_url : module.galaxy.endpoint
  #ncbi_user = ""
  #ncbi_password = ""
  debug = var.debug
  host_port = var.host_port
  network = module.galaxy.network
  db_image = "mariadb:10.5.4"
  user_data_volume = docker_volume.user_data
  #plugins = []
  #additional_repos = []
}