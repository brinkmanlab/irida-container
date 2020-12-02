module "k8s" {
  source = "../../k8s/storage"

  app_name = var.app_name
  data_dir = var.data_dir
  image_tag = var.image_tag
  instance = var.instance
  irida_image = var.irida_image
  nfs_server = var.nfs_server
  user_data_volume_name = var.user_data_volume_name
  namespace = var.namespace
}