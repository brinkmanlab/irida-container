resource "time_static" "now" {}

resource "aws_db_instance" "irida_db" {
  identifier            = "${local.db_name}${local.name_suffix}"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  engine                = "MariaDB" # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  #engine_version       = "5.7"
  instance_class = "db.t3.micro" # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  name           = local.db_conf.name
  username       = local.db_conf.user
  password       = local.db_conf.pass
  #parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids    = var.vpc_security_group_ids
  db_subnet_group_name      = var.db_subnet_group_name
  publicly_accessible       = false
  skip_final_snapshot       = var.debug
  final_snapshot_identifier = "${local.db_conf.name}-${formatdate("YYYYMMDDhhmmss", time_static.now.rfc3339)}"
}

## Register database in internal DNS
resource "kubernetes_service" "irida_db" {
  metadata {
    name      = local.db_conf.host
    namespace = local.namespace.metadata.0.name
  }
  spec {
    type          = "ExternalName"
    external_name = aws_db_instance.irida_db.address
  }
}