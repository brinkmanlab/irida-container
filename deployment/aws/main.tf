provider "aws" {
  region  = var.region
}

module "cloud" {
  source             = "github.com/brinkmanlab/cloud_recipes.git//aws" #?ref=v0.1.2"
  cluster_name       = var.instance
  autoscaler_version = "1.17.3"
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

module "galaxy" {
  source   = "github.com/brinkmanlab/galaxy-container.git//destinations/aws"
  instance = var.instance
  galaxy_conf = {
    require_login       = true
    allow_user_creation = false
  }
  image_tag   = "dev"
  admin_users = [var.email]
  email       = var.email
  debug       = var.debug
  eks         = module.cloud.eks
  vpc         = module.cloud.vpc
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
  load_config_file       = false
}

module "admin_user" {
  source         = "github.com/brinkmanlab/galaxy-container.git//modules/bootstrap_admin"
  email          = var.email
  galaxy_url     = "http://${module.galaxy.endpoint}"
  master_api_key = module.galaxy.master_api_key
  username       = "admin"
}

provider "galaxy" {
  host    = "http://${module.galaxy.endpoint}"
  apikey = module.admin_user.api_key
}

module "irida" {
  source                 = "../../destinations/aws"
  depends_on             = [module.cloud.eks]
  instance               = var.instance
  image_tag              = "dev"
  galaxy_api_key         = module.admin_user.api_key
  galaxy_user_email      = var.email
  mail_from              = var.email
  mail_user              = module.galaxy.smtp_conf["smtp_username"]
  mail_password          = module.galaxy.smtp_conf["smtp_password"]
  base_url               = var.base_url #!= "" ? var.base_url : module.galaxy.endpoint
  nfs_server             = module.galaxy.efs_user_data
  vpc_security_group_ids = [module.cloud.eks.worker_security_group_id]
  db_subnet_group_name   = module.cloud.vpc.database_subnet_group
  #ncbi_user = ""
  #ncbi_password = ""
  debug = var.debug
}