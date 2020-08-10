resource "aws_db_instance" "irida_db" {
  identifier            = "${var.db_name}${var.name_suffix}"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  engine                = "MariaDB" # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  #engine_version       = "5.7"
  instance_class = "db.t3.micro" # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  name                 = local.db_conf.name
  username = local.db_conf.user
  password = local.db_conf.pass
  #parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [module.galaxy.eks.worker_security_group_id]
  db_subnet_group_name = module.galaxy.vpc.database_subnet_group
  publicly_accessible = false
  skip_final_snapshot = true  # TODO temporary, don't need to make snapshots while debugging
  final_snapshot_identifier = local.db_conf.name
}

## Register database in internal DNS
resource "kubernetes_service" "irida_db" {
  depends_on = [module.galaxy.eks.cluster_id]
  metadata {
    name = local.db_conf.host
  }
  spec {
    type          = "ExternalName"
    external_name = aws_db_instance.irida_db.address
  }
}