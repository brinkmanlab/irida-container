locals {
  network = length(docker_network.irida_network) == 1 ? docker_network.irida_network[0].name : var.network
}

resource "random_password" "db_root" {
  length = 16
}

resource "docker_image" "irida_app" {
  name = "${var.irida_image}:${var.image_tag}"
}

resource "docker_image" "irida_db" {
  name = var.db_image
}

resource "docker_volume" "user_data" {
  name = "${var.user_data_volume_name}${var.name_suffix}"
}

resource "docker_volume" "db_data" {
  name = "${var.db_data_volume_name}${var.name_suffix}"
}

resource "docker_network" "irida_network" {
  count = var.network == "" ? 1 : 0
  name  = "galaxy_network${var.name_suffix}"
}

resource "docker_container" "irida_app" {
  for_each   = merge([for k, v in local.profiles : { for i in range(lookup(local.replicates, k, 1)) : "${k}${i}" => v }]...)
  name       = "${var.app_name}${var.name_suffix}_${each.key}"
  image      = docker_image.irida_app.latest
  hostname   = "irida-app-${each.key}"
  domainname = "irida-app-${each.key}"
  restart    = "unless-stopped"
  must_run   = true
  #user       = "irida:irida"
  env = [
    "JAVA_OPTS=-D${join(" -D", compact(local.irida_config))} -Dspring.profiles.active=${join(",", each.value)}",
  ]
  dynamic "ports" {
    for_each = local.replicates.front == 1 && each.key == "front0" ? { port : 80 } : {}
    content {
      external = ports.value
      internal = ports.value
    }
  }
  networks_advanced {
    name = local.network
  }
  mounts {
    source = docker_volume.user_data.name
    target = var.data_dir
    type   = "volume"
  }
  depends_on = [docker_container.irida_db]
}

resource "docker_container" "irida_db" {
  name       = "${var.db_name}${var.name_suffix}"
  image      = docker_image.irida_db.latest
  hostname   = "irida-db"
  domainname = "irida-db"
  restart    = "unless-stopped"
  must_run   = true
  env = [
    "MYSQL_PASSWORD=${var.db_password}",
    "MYSQL_USER=${var.db_user}",
    "MYSQL_DATABASE=${var.db}",
    "MYSQL_ROOT_PASSWORD=${random_password.db_root.result}",
  ]
  mounts {
    source = docker_volume.db_data.name
    target = "/var/lib/mysql"
    type   = "volume"
  }
  networks_advanced {
    name = local.network
  }
}