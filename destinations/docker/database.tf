resource "random_password" "db_root" {
  length = 16
}

resource "docker_image" "irida_db" {
  name = var.db_image
}

resource "docker_container" "irida_db" {
  name       = "${local.db_name}${local.name_suffix}"
  image      = docker_image.irida_db.latest
  hostname   = local.db_name
  domainname = local.db_name
  restart    = "unless-stopped"
  must_run   = true
  user = "mysql"
  env = [
    "MYSQL_PASSWORD=${local.db_conf.pass}",
    "MYSQL_USER=${local.db_conf.user}",
    "MYSQL_DATABASE=${local.db_conf.name}",
    "MYSQL_ROOT_PASSWORD=${random_password.db_root.result}",
  ]
  mounts {
    source = docker_volume.db_data.name
    target = "/var/lib/mysql"
    type   = "volume"
  }
  networks_advanced {
    name = local.network
    aliases = [local.db_conf.host]
  }
}

resource "docker_container" "wait_for_db" {
  depends_on = [docker_container.irida_db]
  image = docker_image.irida_db.latest
  name = "wait_for_db"
  must_run = false
  attach = true
  user = "mysql"
  command = ["bash", "-c", "until mysql -e '\\q' -h '${local.db_conf.host}' -u '${local.db_conf.user}' --password='${local.db_conf.pass}'; do sleep 1; done"]
  networks_advanced {
    name = local.network
    aliases = [local.db_name]
  }
}