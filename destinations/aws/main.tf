locals {
  namespace = var.namespace != null ? var.namespace : kubernetes_namespace.instance[0]
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
  mail_from             = var.mail_from
  mail_password         = var.mail_password
  mail_user             = var.mail_user
  app_name              = local.app_name
  db_name               = local.db_name
  data_dir              = local.data_dir
  tmp_dir               = local.tmp_dir
  user_data_volume_name = local.user_data_volume_name
  db_data_volume_name   = local.db_data_volume_name
  nfs_server            = var.nfs_server
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
  namespace             = local.namespace
}