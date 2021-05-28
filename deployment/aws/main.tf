provider "aws" {
  region  = var.region
}

module "cloud" {
  source             = "github.com/brinkmanlab/cloud_recipes.git//aws" #?ref=v0.1.2"
  cluster_name       = var.instance
  autoscaler_version = "1.20.0"
  #docker_registry_proxies = {
  #  quay = {
  #    hostname = "quay.io"
  #    url = "https://quay.io"
  #    username = var.quay_io_user
  #    password = var.quay_io_password
  #  }
  #}
  debug = var.debug
}

data "aws_eks_cluster" "cluster" {
  name = module.cloud.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cloud.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "instance" {
  metadata {
    name = var.instance
  }
}

module "galaxy-storage" {
  source = "github.com/brinkmanlab/galaxy-container.git//destinations/aws/storage"
  instance = var.instance
  user_data_volume_name = "user-data-${var.instance}"
  vpc = module.cloud.vpc
}

module "irida-storage" {
  source = "../../destinations/aws/storage"
  namespace = kubernetes_namespace.instance
  nfs_server = module.galaxy-storage.nfs_server
  app_name = "irida-app"
  data_dir = "/irida"
  image_tag = "dev"
  instance = var.instance
  irida_image = "brinkmanlab/irida-app"
  user_data_volume_name = "user-data-${var.instance}"
}

module "galaxy" {
  source   = "github.com/brinkmanlab/galaxy-container.git//destinations/aws"
  instance = var.instance
  namespace = kubernetes_namespace.instance
  galaxy_conf = {
    require_login       = true
    allow_user_creation = false
    email_from = var.email
  }
  image_tag   = "latest"
  admin_users = [var.email]
  email       = var.email
  debug       = var.debug
  eks         = module.cloud.eks
  vpc         = module.cloud.vpc
  nfs_server = module.galaxy-storage.nfs_server
  extra_job_mounts = module.irida-storage.extra_job_mounts
  extra_mounts = module.irida-storage.extra_mounts
  tool_mappings = yamldecode(file("../../tool_mapping.yml"))
}

provider "galaxy" {
  host    = "http://${module.galaxy.endpoint}"
  apikey = module.admin_user.api_key
}

module "admin_user" {
  source         = "github.com/brinkmanlab/galaxy-container.git//modules/bootstrap_admin"
  email          = var.email
  galaxy_url     = "http://${module.galaxy.endpoint}"
  master_api_key = module.galaxy.master_api_key
  username       = "admin"
}

module "irida" {
  source                 = "../../destinations/aws"
  instance               = var.instance
  namespace              = kubernetes_namespace.instance
  image_tag              = "latest"
  galaxy_api_key         = module.admin_user.api_key
  galaxy_user_email      = var.email
  mail_config = {
    host = split(":", module.galaxy.smtp_conf.smtp_server)[0]
    port = split(":", module.galaxy.smtp_conf.smtp_server)[1]
    username = module.galaxy.smtp_conf.smtp_username
    password = module.galaxy.smtp_conf.smtp_password
    from = var.email
  }
  base_url               = var.base_url #!= "" ? var.base_url : module.galaxy.endpoint
  claim_name             = module.irida-storage.claim_name
  vpc_security_group_ids = [module.cloud.eks.worker_security_group_id]
  db_subnet_group_name   = module.cloud.vpc.database_subnet_group
  #ncbi_user = ""
  #ncbi_password = ""
  debug = var.debug
  #plugins = []
  #additional_repos = []
}