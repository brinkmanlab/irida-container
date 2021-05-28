locals {
  network = length(docker_network.irida_network) == 1 ? docker_network.irida_network[0].name : var.network
}

resource "docker_network" "irida_network" {
  count = var.network == "" ? 1 : 0
  name  = "irida_network${local.name_suffix}"
}

resource "docker_image" "irida_app" {
  name = "${local.irida_image}:${var.image_tag}"
}

module "galaxy" {
  source = "../galaxy"

  irida_image           = var.irida_image
  image_tag             = var.image_tag
  db_conf               = local.db_conf
  instance              = var.instance
  base_url              = var.base_url
  galaxy_api_key        = var.galaxy_api_key
  galaxy_user_email     = var.galaxy_user_email
  mail_config           = var.mail_config
  irida_config          = var.irida_config
  web_config            = var.web_config
  app_name              = local.app_name
  db_name               = local.db_name
  data_dir              = local.data_dir
  tmp_dir               = local.tmp_dir
  user_data_volume_name = local.user_data_volume_name
  db_data_volume_name   = local.db_data_volume_name
  hide_workflows        = var.hide_workflows
  front_replicates      = var.front_replicates
  processing_replicates = var.processing_replicates
  debug                 = var.debug
  plugins               = var.plugins
  additional_repos      = var.additional_repos
}