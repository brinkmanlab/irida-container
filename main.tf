locals {
  mail_name      = regex("(?m)^mail.*hostname=(?P<mail_name>[^ ]+)", file("${path.root}/galaxy/inventory.ini")).mail_name
  mail_port      = regex("(?m)^mail.*port=(?P<mail_port>[^ ]+)", file("${path.root}/inventory.ini")).mail_port
  name_suffix    = var.instance != "" ? "-${var.instance}" : ""
  debug          = true
  region = "us-west-2"
}

## Docker Config

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

## AWS Config

provider "aws" {
  region  = local.region
  version = "~> 2.0"
}

module "cloud" {
  count = var.create_cloud ? 1 : 0
  source = "git@github.com:brinkmanlab/cloud_recipies.git//aws"
  cluster_name = "IslandCompare"
  instance = var.instance
  debug = local.debug
}

data "terraform_remote_state" "cloud" {
  count = var.create_cloud ? 0 : 1
  backend = "remote"
  config {
    # TODO
  }
}

module "galaxy_aws" {
  #count = var.destination == "aws" ? 1 : 0
  source                  = "git@github.com:brinkmanlab/galaxy-container.git//destinations/aws"
  cluster_name            = "irida${local.name_suffix}"
  instance                = var.instance
  galaxy_conf = {
    email_from          = var.email
    error_email_to      = var.email
    require_login       = true
    allow_user_creation = false
  }
  image_tag = var.image_tag
  mail_name = local.mail_name
  mail_port = local.mail_port
  email     = var.email
  debug     = local.debug
}

data "aws_eks_cluster" "cluster" {
  name = module.galaxy_aws.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.galaxy_aws.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "restapi" {
  uri                  = "http:"
  write_returns_object = true
}

resource "random_password" "irida_user" {
  length  = 16
  special = false
}

resource "restapi_object" "irida_user" {
  depends_on   = [module.galaxy_aws.endpoint]
  path         = "//${replace(module.galaxy_aws.endpoint, "http://", "")}/api/users?key=${module.galaxy_aws.master_api_key}"
  create_path  = "//${replace(module.galaxy_aws.endpoint, "http://", "")}/api/users?key=${module.galaxy_aws.master_api_key}"
  read_path    = "//${replace(module.galaxy_aws.endpoint, "http://", "")}/api/users/{id}?key=${module.galaxy_aws.master_api_key}"
  update_path  = "//${replace(module.galaxy_aws.endpoint, "http://", "")}/api/users/{id}?key=${module.galaxy_aws.master_api_key}"
  destroy_path = "//${replace(module.galaxy_aws.endpoint, "http://", "")}/api/users/{id}?key=${module.galaxy_aws.master_api_key}"
  data = jsonencode({
    username = "irida1"
    password = random_password.irida_user.result
    email    = "irida1@irida.ca"
  })
}

resource "null_resource" "fetch_api_key" {
  depends_on = [restapi_object.irida_user]
  triggers = {
    user = restapi_object.irida_user.id
  }
  provisioner "local-exec" {
    command = "curl --user 'irida1@irida.ca:${random_password.irida_user.result}' -o api_key.json -- ${module.galaxy_aws.endpoint}/api/authenticate/baseauth"
  }
}

data "local_file" "api_key" {
  depends_on = [null_resource.fetch_api_key]
  filename   = "api_key.json"
}

module "irida_aws" {
  #count = var.destination == "aws" ? 1 : 0
  source                = "./destinations/aws"
  depends_on            = [module.galaxy_aws.eks]
  image_tag             = var.image_tag
  instance              = var.instance
  galaxy_api_key        = jsondecode(data.local_file.api_key.content).api_key
  galaxy_user_email     = "irida1@irida.ca"
  mail_from             = var.email
  mail_user             = module.galaxy_aws.smtp_conf["smtp_username"]
  mail_password         = module.galaxy_aws.smtp_conf["smtp_password"]
  base_url               = var.base_url #!= "" ? var.base_url : module.galaxy_aws.endpoint
  nfs_server             = module.galaxy_aws.efs_user_data
  vpc_security_group_ids = [module.galaxy_aws.eks.worker_security_group_id]
  db_subnet_group_name   = module.galaxy_aws.vpc.database_subnet_group
  #ncbi_user = ""
  #ncbi_password = ""
  debug = local.debug
}