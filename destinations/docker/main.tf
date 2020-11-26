locals {
  network = length(docker_network.irida_network) == 1 ? docker_network.irida_network[0].name : var.network
}

resource "docker_network" "irida_network" {
  count = var.network == "" ? 1 : 0
  name  = "irida_network${local.name_suffix}"
}

resource "docker_image" "irida_app" {
  name = "${var.irida_image}:${var.image_tag}"
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
  mail_from             = var.mail_from
  mail_password         = var.mail_password
  mail_user             = var.mail_user
  app_name              = local.app_name
  db_name               = local.db_name
  data_dir              = local.data_dir
  tmp_dir               = local.tmp_dir
  user_data_volume_name = local.user_data_volume_name
  db_data_volume_name   = local.db_data_volume_name
  analysis_warning      = var.analysis_warning
  help_email            = var.help_email
  help_title            = var.help_title
  help_url              = var.help_url
  hide_workflows        = var.hide_workflows
  ncbi_user             = var.ncbi_user
  ncbi_password         = var.ncbi_password
  front_replicates      = var.front_replicates
  processing_replicates = var.processing_replicates
  debug                 = var.debug
}