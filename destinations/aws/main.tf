module "galaxy" {
  source = "../../galaxy/destinations/aws"
  instance = var.instance
  cluster_name = var.cluster_name
}

module "irida-k8s" {
  source                  = "../k8s"
  depends = module.galaxy.eks.cluster_id
  irida_image             = var.irida_image
  image_tag               = var.image_tag
  db_conf                 = local.db_conf
  instance                = var.instance
  name_suffix             = var.name_suffix
  base_url                = local.base_url
  galaxy_api_key          = var.galaxy_api_key
  galaxy_user_email       = var.galaxy_user_email
  mail_from               = var.mail_from
  mail_password           = var.mail_password
  mail_user               = var.mail_user
  object_store_access_key = var.object_store_access_key
  object_store_secret_key = var.object_store_secret_key
  app_name                = var.app_name
  db_name                 = var.db_name
  data_dir                = var.data_dir
  user_data_volume_name   = var.user_data_volume_name
  db_data_volume_name     = var.db_data_volume_name
  nfs_server = module.galaxy.efs_user_data
}