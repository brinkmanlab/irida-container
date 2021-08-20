locals {
  namespace = var.namespace != null ? var.namespace : kubernetes_namespace.instance[0]
  galaxy_repositories = module.k8s.galaxy_repositories
}

resource "kubernetes_namespace" "instance" {
  count = var.namespace == null ? 1 : 0
  metadata {
    name = local.instance
  }
}

module "k8s" {
  source                = "../k8s"
  depends_on = [kubernetes_service.irida_db]
  irida_image           = var.irida_image
  image_tag             = var.image_tag
  db_conf               = local.db_conf
  instance              = local.instance
  base_url              = local.base_url
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
  claim_name            = var.claim_name
  hide_workflows        = var.hide_workflows
  front_replicates      = var.front_replicates
  processing_replicates = var.processing_replicates
  debug                 = var.debug
  namespace             = local.namespace
  plugins               = var.plugins
  additional_repos      = var.additional_repos
  lb_annotations        = var.lb_annotations
  custom_pages          = var.custom_pages
}